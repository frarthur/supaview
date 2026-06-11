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
    String? serviceRoleKey,
  })  : _client = SupabaseClient(supabaseUrl, anonKey),
        _adminClient = serviceRoleKey != null && serviceRoleKey.isNotEmpty
            ? SupabaseClient(supabaseUrl, serviceRoleKey)
            : null;

  final SupabaseClient _client;
  final SupabaseClient? _adminClient;

  Future<ProjectStats> fetchStats() async {
    final tablesCount = await _fetchTablesCount();
    final storageBucketsCount = await _fetchStorageBucketsCount();
    final usersCount = await _fetchUsersCount();
    final isConnected =
        tablesCount > 0 || storageBucketsCount > 0 || usersCount > 0;

    return ProjectStats(
      tablesCount: tablesCount,
      storageBucketsCount: storageBucketsCount,
      usersCount: usersCount,
      isConnected: isConnected,
    );
  }

  Future<int> _fetchTablesCount() async {
    try {
      final response = await _client
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public')
          .timeout(const Duration(seconds: 10));
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchStorageBucketsCount() async {
    try {
      final response =
          await _client.storage.listBuckets().timeout(
                const Duration(seconds: 10),
              );
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchUsersCount() async {
    try {
      final client = _adminClient ?? _client;
      final response =
          await client.auth.admin.listUsers().timeout(
                const Duration(seconds: 10),
              );
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  void dispose() {
    _client.dispose();
    _adminClient?.dispose();
  }
}
