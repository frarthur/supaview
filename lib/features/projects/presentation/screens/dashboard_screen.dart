import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/supabase_stats_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/providers/dashboard_providers.dart';
import 'package:supaview/features/projects/presentation/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(projectStatsProvider(project));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(projectStatsProvider(project).future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConnectionHeader(context),
          const SizedBox(height: 24),
          statsAsync.when(
            data: (stats) => _buildStatsGrid(context, stats),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 8),
                    const Text('Could not load stats'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = projectStatsProvider(project);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.dns_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.supabaseUrl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, _) {
                final stats = ref.watch(statsAsync);
                return stats.when(
                  data: (data) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: data.isConnected
                          ? Colors.green.withAlpha(30)
                          : Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: data.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.isConnected ? 'Online' : 'Offline',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: data.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Error',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProjectStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        StatCard(
          icon: Icons.table_chart,
          label: 'Tables',
          value: stats.tablesCount.toString(),
          color: Colors.indigo,
          onTap: () {},
        ),
        StatCard(
          icon: Icons.folder,
          label: 'Storage Buckets',
          value: stats.storageBucketsCount.toString(),
          color: Colors.amber,
          onTap: () {},
        ),
        StatCard(
          icon: Icons.people,
          label: 'Users',
          value: stats.usersCount.toString(),
          color: Colors.teal,
          onTap: () {},
        ),
        StatCard(
          icon: Icons.more_horiz,
          label: 'More features',
          value: '...',
          color: Colors.purple,
          onTap: () {},
        ),
      ],
    );
  }
}
