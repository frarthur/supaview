import 'package:http/http.dart' as http;
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
  })  : _supabaseUrl = supabaseUrl,
        _anonKey = anonKey,
        _client = SupabaseClient(supabaseUrl, anonKey),
        _adminClient = serviceRoleKey != null && serviceRoleKey.isNotEmpty
            ? SupabaseClient(supabaseUrl, serviceRoleKey)
            : null;

  final String _supabaseUrl;
  final String _anonKey;
  final SupabaseClient _client;
  final SupabaseClient? _adminClient;

  Future<ProjectStats> fetchStats() async {
    final isConnected = await _checkConnection();
    if (!isConnected) {
      return ProjectStats(
        tablesCount: 0,
        storageBucketsCount: 0,
        usersCount: 0,
        isConnected: false,
      );
    }

    final results = await Future.wait([
      _fetchTablesCount(),
      _fetchStorageBucketsCount(),
      _fetchUsersCount(),
    ]);

    return ProjectStats(
      tablesCount: results[0],
      storageBucketsCount: results[1],
      usersCount: results[2],
      isConnected: true,
    );
  }

  Future<bool> _checkConnection() async {
    try {
      final url = '$_supabaseUrl/rest/v1/';
      final response = await http.get(
        Uri.parse(url),
        headers: {'apikey': _anonKey},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 401 || response.statusCode == 400;
    } catch (_) {
      return false;
    }
  }

  Future<int> _fetchTablesCount() async {
    try {
      final response = await _client
          .from('information_schema.tables')
          .select('table_name')
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
      final client = _adminClient ?? _client;
      final response = await client.auth.admin.listUsers();
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
