import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/storage_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

final storageServiceProvider = Provider.family<StorageService, Project>(
  (ref, project) => StorageService(
    supabaseUrl: project.supabaseUrl,
    anonKey: project.anonKey,
    serviceRoleKey: project.serviceRoleKey,
  ),
);

final bucketsProvider = FutureProvider.family<List<StorageBucket>, Project>(
  (ref, project) async {
    final service = ref.watch(storageServiceProvider(project));
    return service.listBuckets();
  },
);
