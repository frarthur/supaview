import 'dart:convert';

import 'package:http/http.dart' as http;

class StorageBucket {
  StorageBucket({required this.name, required this.isPublic});
  final String name;
  final bool isPublic;
}

class StorageFile {
  StorageFile({
    required this.name,
    required this.bucket,
    required this.updatedAt,
    this.isFolder = false,
    this.size = 0,
  });

  final String name;
  final String bucket;
  final DateTime updatedAt;
  final bool isFolder;
  final int size;

  String get extension =>
      isFolder ? '' : name.contains('.') ? name.split('.').last : '';
}

class StorageService {
  StorageService({
    required String supabaseUrl,
    required String anonKey,
    String? serviceRoleKey,
  })  : _baseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _key = serviceRoleKey ?? anonKey;

  final String _baseUrl;
  final String _key;

  Future<List<StorageBucket>> listBuckets() async {
    final url = Uri.parse('${_baseUrl}storage/v1/bucket');
    final response = await http
        .get(url, headers: {
          'authorization': 'Bearer $_key',
          'apiKey': _key,
        })
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List;
      return body.map((b) {
        final m = b as Map<String, dynamic>;
        return StorageBucket(
          name: m['name'] as String? ?? '',
          isPublic: m['public'] as bool? ?? false,
        );
      }).toList();
    }
    return [];
  }

  Future<List<StorageFile>> listFiles(String bucket, {String path = ''}) async {
    final url =
        Uri.parse('${_baseUrl}storage/v1/object/list/$bucket');
    final response = await http
        .post(
          url,
          headers: {
            'authorization': 'Bearer $_key',
            'apiKey': _key,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'prefix': path,
            'limit': 100,
            'offset': 0,
            'sortBy': {'column': 'name', 'order': 'asc'},
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List;
      return body.map((f) {
        final m = f as Map<String, dynamic>;
        final name = m['name'] as String? ?? '';
        return StorageFile(
          name: name.split('/').last,
          bucket: bucket,
          updatedAt: DateTime.tryParse(m['updated_at'] as String? ?? '') ??
              DateTime.now(),
          isFolder: m['id'] == null,
          size: (m['metadata'] as Map<String, dynamic>?)?['size'] as int? ?? 0,
        );
      }).toList();
    }
    return [];
  }

  String getPublicUrl(String bucket, String path) {
    return '${_baseUrl}storage/v1/object/public/$bucket/$path';
  }

  Future<void> deleteFile(String bucket, String path) async {
    final url = Uri.parse('${_baseUrl}storage/v1/object/$bucket/$path');
    await http.delete(url, headers: {
      'authorization': 'Bearer $_key',
      'apiKey': _key,
    });
  }

  Future<void> deleteFolder(String bucket, String path) async {
    final files = await listFiles(bucket, path: path);
    for (final f in files) {
      if (f.isFolder) {
        await deleteFolder(bucket, '$path/${f.name}');
      } else {
        await deleteFile(bucket, '$path/${f.name}');
      }
    }
  }
}
