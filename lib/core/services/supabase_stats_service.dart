import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectStats {
  ProjectStats({
    required this.tablesCount,
    required this.storageBucketsCount,
    required this.usersCount,
    required this.storageSizeBytes,
    required this.recentUsers,
    required this.isConnected,
    this.lastActivity,
  });

  final int tablesCount;
  final int storageBucketsCount;
  final int usersCount;
  final int storageSizeBytes;
  final int recentUsers;
  final bool isConnected;
  final String? lastActivity;

  String get storageSizeFormatted {
    if (storageSizeBytes < 1024) return '$storageSizeBytes B';
    if (storageSizeBytes < 1024 * 1024) {
      return '${(storageSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (storageSizeBytes < 1024 * 1024 * 1024) {
      return '${(storageSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(storageSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class SupabaseStatsService {
  SupabaseStatsService({
    required String supabaseUrl,
    required String anonKey,
    String? serviceRoleKey,
  })  : _baseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _anonKey = anonKey,
        _key = serviceRoleKey ?? anonKey,
        _client = SupabaseClient(supabaseUrl, anonKey),
        _adminClient = serviceRoleKey != null && serviceRoleKey.isNotEmpty
            ? SupabaseClient(supabaseUrl, serviceRoleKey)
            : null;

  final String _baseUrl;
  final String _anonKey;
  final String _key;
  final SupabaseClient _client;
  final SupabaseClient? _adminClient;

  Future<ProjectStats> fetchStats() async {
    final connected = await _healthCheck();
    if (!connected) {
      return ProjectStats(
        tablesCount: 0,
        storageBucketsCount: 0,
        usersCount: 0,
        storageSizeBytes: 0,
        recentUsers: 0,
        isConnected: false,
      );
    }

    final tables = await _fetchTablesCount();
    final buckets = await _fetchStorageBucketsCount();
    final users = await _fetchUsersCount();
    final storageBytes = await _fetchStorageSize();
    final recent = await _fetchRecentUsers();
    final activity = await _fetchLastActivity();

    return ProjectStats(
      tablesCount: tables,
      storageBucketsCount: buckets,
      usersCount: users,
      storageSizeBytes: storageBytes,
      recentUsers: recent,
      isConnected: true,
      lastActivity: activity,
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
      final response = await http.get(
        Uri.parse('${_baseUrl}rest/v1/'),
        headers: {
          'apikey': _key,
          'Authorization': 'Bearer $_key',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return 0;
      final spec = jsonDecode(response.body) as Map<String, dynamic>;
      final paths = spec['paths'] as Map<String, dynamic>?;
      if (paths == null) return 0;
      final tablePattern = RegExp(r'^/[a-zA-Z][a-zA-Z0-9_]*$');
      return paths.keys.where((p) => tablePattern.hasMatch(p)).length;
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

  Future<int> _fetchStorageSize() async {
    try {
      final buckets = await _client.storage.listBuckets();
      int total = 0;
      for (final bucket in buckets) {
        try {
          final listUrl = Uri.parse('${_baseUrl}storage/v1/object/list/${bucket.name}');
          final resp = await http.post(
            listUrl,
            headers: {
              'authorization': 'Bearer $_key',
              'apiKey': _key,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'prefix': '',
              'limit': 1000,
              'offset': 0,
            }),
          ).timeout(const Duration(seconds: 10));
          if (resp.statusCode == 200) {
            final files = jsonDecode(resp.body) as List;
            for (final f in files) {
              final metadata = (f as Map)['metadata'] as Map?;
              final size = metadata?['size'] as int? ?? 0;
              total += size;
            }
          }
        } catch (_) {}
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchRecentUsers() async {
    try {
      final client = _adminClient ?? _client;
      final users = await client.auth.admin.listUsers();
      final dayAgo = DateTime.now().subtract(const Duration(hours: 24));
      return users.where((u) {
        final created = u.createdAt;
        if (created == null) return false;
        final dt = created is DateTime
            ? (created as DateTime)
            : DateTime.tryParse(created.toString());
        return dt != null && dt.isAfter(dayAgo);
      }).length;
    } catch (_) {
      return 0;
    }
  }

  Future<String?> _fetchLastActivity() async {
    try {
      final tables = await _discoverTableNames();
      if (tables.isEmpty) return null;

      String? best;
      DateTime? bestTime;
      final cols = ['updated_at', 'created_at', 'last_login'];

      for (final name in tables) {
        for (final col in cols) {
          try {
            final url = '${_baseUrl}rest/v1/$name?order=$col.desc&limit=1';
            final resp = await http.get(
              Uri.parse(url),
              headers: {'apikey': _key, 'Authorization': 'Bearer $_key'},
            ).timeout(const Duration(seconds: 4));
            if (resp.statusCode == 200) {
              final rows = jsonDecode(resp.body) as List;
              if (rows.isNotEmpty) {
                final row = rows.first as Map;
                final val = row[col];
                if (val != null) {
                  final dt = DateTime.tryParse(val.toString());
                  if (dt != null && (bestTime == null || dt.isAfter(bestTime))) {
                    bestTime = dt;
                    best = '$name ${_timeAgo(val.toString())}';
                  }
                }
              }
            }
          } catch (_) {}
        }
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _discoverTableNames() async {
    try {
      final resp = await http.get(
        Uri.parse('${_baseUrl}rest/v1/'),
        headers: {'apikey': _key, 'Authorization': 'Bearer $_key'},
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];
      final paths = (jsonDecode(resp.body) as Map)['paths'] as Map?;
      if (paths == null) return [];
      final pattern = RegExp(r'^/[a-zA-Z][a-zA-Z0-9_]*$');
      return paths.keys
          .whereType<String>()
          .where((p) => pattern.hasMatch(p))
          .map((p) => p.substring(1))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return iso;
    }
  }

  void dispose() {
    _client.dispose();
    _adminClient?.dispose();
  }
}
