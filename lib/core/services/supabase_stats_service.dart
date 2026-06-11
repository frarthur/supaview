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
  })  : _baseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _anonKey = anonKey,
        _client = SupabaseClient(supabaseUrl, anonKey),
        _adminClient = serviceRoleKey != null && serviceRoleKey.isNotEmpty
            ? SupabaseClient(supabaseUrl, serviceRoleKey)
            : null;

  final String _baseUrl;
  final String _anonKey;
  final SupabaseClient _client;
  final SupabaseClient? _adminClient;

  Future<ProjectStats> fetchStats() async {
    final isConnected = await _healthCheck();
    if (!isConnected) {
      return ProjectStats(
        tablesCount: 0,
        storageBucketsCount: 0,
        usersCount: 0,
        isConnected: false,
      );
    }

    final tablesCount = await _fetchTablesCount();
    final storageBucketsCount = await _fetchStorageBucketsCount();
    final usersCount = await _fetchUsersCount();

    return ProjectStats(
      tablesCount: tablesCount,
      storageBucketsCount: storageBucketsCount,
      usersCount: usersCount,
      isConnected: true,
    );
  }

  Future<bool> _healthCheck() async {
    try {
      await http
          .get(
            Uri.parse('${_baseUrl}rest/v1/'),
            headers: {
              'apikey': _anonKey,
              'Authorization': 'Bearer $_anonKey',
            },
          )
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int> _fetchTablesCount() async {
    try {
      final response = await http
          .get(
            Uri.parse('${_baseUrl}rest/v1/'),
            headers: {
              'apikey': _anonKey,
              'Authorization': 'Bearer $_anonKey',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return 0;

      final spec = jsonDecode(response.body) as Map<String, dynamic>;
      final paths = spec['paths'] as Map<String, dynamic>?;
      if (paths == null) return 0;

      final tables = paths.keys
          .where((path) =>
              path.startsWith('/') &&
              !path.contains('{') &&
              !path.startsWith('/rpc'))
          .map((path) => path.substring(1))
          .toList();
      return tables.length;
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
