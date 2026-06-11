import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supaview/features/tables/domain/entities/column_info.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';

class TableDataService {
  TableDataService({
    required String supabaseUrl,
    required String anonKey,
    String? serviceRoleKey,
  })  : _baseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _anonKey = anonKey,
        _serviceRoleKey = serviceRoleKey;

  final String _baseUrl;
  final String _anonKey;
  final String? _serviceRoleKey;

  String get _key => _serviceRoleKey ?? _anonKey;

  Future<List<TableInfo>> fetchTables() async {
    final tableNames = await _discoverTableNames();
    if (tableNames.isEmpty) return [];

    final tables = <TableInfo>[];
    for (final name in tableNames) {
      final columns = await _inferColumns(name);
      tables.add(TableInfo(
        name: name,
        schema: 'public',
        columns: columns,
        rowCount: 0,
      ));
    }
    return tables;
  }

  Future<List<String>> _discoverTableNames() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}rest/v1/'),
        headers: {
          'apikey': _key,
          'Authorization': 'Bearer $_key',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final spec = jsonDecode(response.body) as Map<String, dynamic>;
      final paths = spec['paths'] as Map<String, dynamic>?;
      if (paths == null) return [];

      return paths.keys
          .where((path) =>
              path.startsWith('/') &&
              !path.contains('{') &&
              !path.startsWith('/rpc'))
          .map((path) => path.substring(1))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ColumnInfo>> _inferColumns(String table) async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}rest/v1/$table?limit=1'),
        headers: {
          'apikey': _anonKey,
          'Authorization': 'Bearer $_anonKey',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List;
        if (body.isNotEmpty) {
          final row = body.first as Map<String, dynamic>;
          return row.keys.map((key) {
            final value = row[key];
            return ColumnInfo(
              name: key,
              dataType: _inferType(value),
              isNullable: value == null,
              isPrimaryKey: false,
            );
          }).toList();
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  String _inferType(dynamic value) {
    if (value == null) return 'text';
    if (value is int) return 'integer';
    if (value is double) return 'numeric';
    if (value is bool) return 'boolean';
    if (value is List) return 'array';
    if (value is Map) return 'json';
    return 'text';
  }

  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    int page = 0,
    int pageSize = 50,
    String? orderBy,
    bool ascending = true,
    String? searchQuery,
    String? searchColumn,
  }) async {
    final from = page * pageSize;

    try {
      final params = <String, String>{
        'select': '*',
        'offset': from.toString(),
        'limit': pageSize.toString(),
      };
      if (orderBy != null) {
        params['order'] = ascending ? '$orderBy.asc' : '$orderBy.desc';
      }
      if (searchQuery != null && searchColumn != null) {
        params[searchColumn] = 'like.*$searchQuery*';
      }

      final url = Uri.parse('$_baseUrl/rest/v1/$table')
          .replace(queryParameters: params);
      final response = await http.get(url, headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$_baseUrl/rest/v1/$table'),
      headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(data),
    );
  }

  Future<void> updateRow(
    String table,
    String primaryKeyColumn,
    dynamic primaryKeyValue,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/rest/v1/$table')
        .replace(queryParameters: {primaryKeyColumn: 'eq.$primaryKeyValue'});
    await http.patch(
      url,
      headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(data),
    );
  }

  Future<void> deleteRow(
    String table,
    String primaryKeyColumn,
    dynamic primaryKeyValue,
  ) async {
    final url = Uri.parse('$_baseUrl/rest/v1/$table')
        .replace(queryParameters: {primaryKeyColumn: 'eq.$primaryKeyValue'});
    await http.delete(
      url,
      headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      },
    );
  }
}
