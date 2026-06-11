import 'dart:convert';

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
  })  : _supabaseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _anonKey = anonKey,
        _serviceRoleKey = serviceRoleKey,
        _client = SupabaseClient(supabaseUrl, anonKey),
        _adminClient = serviceRoleKey != null && serviceRoleKey.isNotEmpty
            ? SupabaseClient(supabaseUrl, serviceRoleKey)
            : null;

  final String _supabaseUrl;
  final String _anonKey;
  final String? _serviceRoleKey;
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

  String get _key => _serviceRoleKey ?? _anonKey;

  Future<int> _fetchTablesCount() async {
    try {
      final url = Uri.parse('${_supabaseUrl}rest/v1/information_schema.tables')
          .replace(queryParameters: {
        'table_schema': 'eq.public',
        'select': 'table_name',
      });
      final response = await http
          .get(
            url,
            headers: {
              'apikey': _key,
              'Authorization': 'Bearer $_key',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List;
        return body.length;
      }
      return 0;
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
