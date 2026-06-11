import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/supabase_stats_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.project});

  final Project project;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _refreshTimer;
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        ref.invalidate(projectStatsProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(projectStatsProvider(widget.project));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(projectStatsProvider(widget.project).future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _buildMonitoringGrid(theme, stats),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.cloud_off, size: 48,
                        color: theme.colorScheme.error),
                    const SizedBox(height: 12),
                    Text('Unable to load stats',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text('$err', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final statsAsync = ref.watch(projectStatsProvider(widget.project));

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
              child: Icon(Icons.dns_outlined,
                  color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.project.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(widget.project.supabaseUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            statsAsync.when(
              data: (s) => _StatusBadge(online: s.isConnected),
              loading: () => const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const _StatusBadge(online: false),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_autoRefresh ? Icons.sync : Icons.sync_disabled),
              tooltip: 'Auto-refresh every 30s',
              onPressed: () => setState(() {
                _autoRefresh = !_autoRefresh;
                _startAutoRefresh();
              }),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringGrid(ThemeData theme, ProjectStats stats) {
    return Column(
      children: [
        _StatsRow(theme: theme, stats: stats),
        const SizedBox(height: 12),
        _ActivityCard(theme: theme, stats: stats),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (online ? Colors.green : Colors.red).withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            online ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: online ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.theme, required this.stats});
  final ThemeData theme;
  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final half = (constraints.maxWidth - 12) / 2;
        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: half,
                  child: _MonitorCard(
                    icon: Icons.table_chart,
                    label: 'Tables',
                    value: stats.tablesCount.toString(),
                    color: Colors.indigo,
                    subtitle: 'Discovered via API',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: half,
                  child: _MonitorCard(
                    icon: Icons.folder,
                    label: 'Storage',
                    value: stats.storageSizeFormatted,
                    color: Colors.amber,
                    subtitle: '${stats.storageBucketsCount} buckets',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: half,
                  child: _MonitorCard(
                    icon: Icons.people,
                    label: 'Users',
                    value: formatNumber(stats.usersCount),
                    color: Colors.teal,
                    subtitle: '${stats.recentUsers} in last 24h',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: half,
                  child: _MonitorCard(
                    icon: Icons.wifi_find,
                    label: 'API Status',
                    value: stats.isConnected ? 'Healthy' : 'Down',
                    color: stats.isConnected ? Colors.green : Colors.red,
                    subtitle: stats.isConnected
                        ? 'Supabase reachable'
                        : 'Connection failed',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _MonitorCard extends StatelessWidget {
  const _MonitorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.circle, size: 8, color: color.withAlpha(100)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.theme,
    required this.stats,
  });

  final ThemeData theme;
  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Activity',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _activityRow(
              icon: Icons.person_add,
              label: 'New users (24h)',
              value: stats.recentUsers.toString(),
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            _activityRow(
              icon: Icons.storage,
              label: 'Storage buckets',
              value: '${stats.storageBucketsCount} buckets',
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _activityRow(
              icon: Icons.check_circle,
              label: 'API health',
              value: stats.isConnected ? 'Operational' : 'Down',
              color: stats.isConnected ? Colors.green : Colors.red,
            ),
            if (stats.lastActivity != null) ...[
              const SizedBox(height: 12),
              _activityRow(
                icon: Icons.history,
                label: 'Last update',
                value: stats.lastActivity!,
                color: Colors.indigo,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Flexible(
          child: Tooltip(
            message: value,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
