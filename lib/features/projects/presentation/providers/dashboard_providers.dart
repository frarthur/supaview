import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/supabase_stats_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

final statsServiceProvider = Provider.family<SupabaseStatsService?, Project>(
  (ref, project) {
    final service = SupabaseStatsService(
      supabaseUrl: project.supabaseUrl,
      anonKey: project.anonKey,
      serviceRoleKey: project.serviceRoleKey,
    );
    ref.onDispose(service.dispose);
    return service;
  },
);

final projectStatsProvider = FutureProvider.family<ProjectStats, Project>(
  (ref, project) async {
    final service = ref.watch(statsServiceProvider(project));
    return service!.fetchStats();
  },
);
