import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/storage_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/storage/presentation/providers/storage_providers.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketsAsync = ref.watch(bucketsProvider(project));

    return bucketsAsync.when(
      data: (buckets) {
        if (buckets.isEmpty) {
          return const Center(child: Text('No storage buckets'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: buckets.length,
          itemBuilder: (context, index) {
            final bucket = buckets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.folder,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                title: Text(bucket.name),
                subtitle: Text(bucket.isPublic ? 'Public' : 'Private'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openBucket(context, bucket),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  void _openBucket(BuildContext context, StorageBucket bucket) {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => _BucketScreen(
          project: project,
          bucketName: bucket.name,
        ),
      ),
    );
  }
}

class _BucketScreen extends ConsumerWidget {
  const _BucketScreen({
    required this.project,
    required this.bucketName,
  });

  final Project project;
  final String bucketName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(storageServiceProvider(project));

    return Scaffold(
      appBar: AppBar(title: Text(bucketName)),
      body: FutureBuilder<List<StorageFile>>(
        future: service.listFiles(bucketName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final files = snapshot.data ?? [];
          if (files.isEmpty) {
            return const Center(child: Text('Bucket is empty'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                leading: Icon(
                  file.isFolder ? Icons.folder : Icons.insert_drive_file,
                  color: file.isFolder ? Colors.amber : Colors.blue,
                ),
                title: Text(file.name),
                subtitle: file.isFolder
                    ? null
                    : Text('${_formatSize(file.size)} · ${file.extension}'),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (_) => [
                    if (!file.isFolder)
                      const PopupMenuItem(value: 'share', child: Text('Share link')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (action) async {
                    if (action == 'delete') {
                      await service.deleteFile(bucketName, file.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${file.name} deleted')),
                        );
                      }
                    } else if (action == 'share') {
                      final url = service.getPublicUrl(bucketName, file.name);
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied!')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
