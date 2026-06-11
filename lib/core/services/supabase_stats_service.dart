import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectStats {
  ProjectStats({
    required this.tablesCount,
    required this.storageBucketsCount,
    required this.usersCount,
    required this.isConnected,
  });

  final int tablesCount;
  final int storageBucketsCount;
  final int usersCount;
  final bool isConnected;
}

class SupabaseStatsService {
  SupabaseStatsService({
    required String supabaseUrl,
    required String anonKey,
  }) : _client = SupabaseClient(supabaseUrl, anonKey);

  final SupabaseClient _client;

  Future<ProjectStats> fetchStats() async {
    try {
      final tablesCount = await _fetchTablesCount();
      final storageBucketsCount = await _fetchStorageBucketsCount();
      final usersCount = await _fetchUsersCount();

      return ProjectStats(
        tablesCount: tablesCount,
        storageBucketsCount: storageBucketsCount,
        usersCount: usersCount,
        isConnected: true,
      );
    } catch (_) {
      return ProjectStats(
        tablesCount: 0,
        storageBucketsCount: 0,
        usersCount: 0,
        isConnected: false,
      );
    }
  }

  Future<int> _fetchTablesCount() async {
    try {
      final response = await _client
          .from('information_schema.tables')
          .select()
          .eq('table_schema', 'public');
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchStorageBucketsCount() async {
    try {
      final response = await _client.storage.listBuckets();
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchUsersCount() async {
    try {
      final response = await _client.auth.admin.listUsers();
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  void dispose() {
    _client.dispose();
  }
}
