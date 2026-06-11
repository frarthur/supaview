import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supaview/features/tables/domain/entities/column_info.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';

class TableDataService {
  TableDataService({
    required String supabaseUrl,
    required String anonKey,
    String? serviceRoleKey,
  })  : _baseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _anonKey = anonKey,
        _serviceRoleKey = serviceRoleKey,
        _client = SupabaseClient(supabaseUrl, anonKey);

  final String _baseUrl;
  final String _anonKey;
  final String? _serviceRoleKey;
  final SupabaseClient _client;

  String get _key => _serviceRoleKey ?? _anonKey;

  Map<String, dynamic>? _specCache;

  Future<List<TableInfo>> fetchTables() async {
    final spec = await _getOpenApiSpec();
    if (spec == null) return [];

    final paths = spec['paths'] as Map<String, dynamic>?;
    if (paths == null) return [];

    final definitions = spec['definitions'] as Map<String, dynamic>?;

    final tables = <TableInfo>[];
    for (final entry in paths.entries) {
      final path = entry.key;
      if (path.contains('{') || path.startsWith('/rpc')) continue;

      final tableName = path.substring(1);
      final columns = _parseColumnsFromSpec(
        path,
        entry.value as Map<String, dynamic>,
        definitions,
      );

      tables.add(TableInfo(
        name: tableName,
        schema: 'public',
        columns: columns,
        rowCount: 0,
      ));
    }
    return tables;
  }

  Future<Map<String, dynamic>?> _getOpenApiSpec() async {
    if (_specCache != null) return _specCache;

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}rest/v1/'),
        headers: {
          'apikey': _key,
          'Authorization': 'Bearer $_key',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final spec = jsonDecode(response.body) as Map<String, dynamic>;
      _specCache = spec;
      return spec;
    } catch (_) {
      return null;
    }
  }

  List<ColumnInfo> _parseColumnsFromSpec(
    String path,
    Map<String, dynamic> pathItem,
    Map<String, dynamic>? definitions,
  ) {
    try {
      final getMethod = pathItem['get'] as Map<String, dynamic>?;
      final responses = getMethod?['responses'] as Map<String, dynamic>?;
      final response200 = responses?['200'] as Map<String, dynamic>?;
      final schema = response200?['schema'] as Map<String, dynamic>?;
      final items = schema?['items'] as Map<String, dynamic>?;
      var properties = items?['properties'] as Map<String, dynamic>?;

      if (properties == null) {
        final ref = items?[r'$ref'] as String?;
        if (ref != null && definitions != null) {
          final defName = ref.split('/').last;
          final def = definitions[defName] as Map<String, dynamic>?;
          properties = def?['properties'] as Map<String, dynamic>?;
        }
      }

      if (properties == null) return [];

      return properties.entries.map((e) {
        final prop = e.value as Map<String, dynamic>?;
        final type = prop?['type'] as String? ?? 'text';
        final format = prop?['format'] as String?;
        return ColumnInfo(
          name: e.key,
          dataType: format != null ? '$type($format)' : type,
          isNullable: true,
          isPrimaryKey: false,
        );
      }).toList();
    } catch (_) {
      return [];
    }
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
    final to = from + pageSize - 1;

    try {
      PostgrestList response;

      if (searchQuery != null && searchColumn != null && orderBy != null) {
        response = await _client
            .from(table)
            .select()
            .ilike(searchColumn, '%$searchQuery%')
            .order(orderBy, ascending: ascending)
            .range(from, to)
            .timeout(const Duration(seconds: 15));
      } else if (searchQuery != null && searchColumn != null) {
        response = await _client
            .from(table)
            .select()
            .ilike(searchColumn, '%$searchQuery%')
            .range(from, to)
            .timeout(const Duration(seconds: 15));
      } else if (orderBy != null) {
        response = await _client
            .from(table)
            .select()
            .order(orderBy, ascending: ascending)
            .range(from, to)
            .timeout(const Duration(seconds: 15));
      } else {
        response = await _client
            .from(table)
            .select()
            .range(from, to)
            .timeout(const Duration(seconds: 15));
      }

      final list = response.map((r) => Map<String, dynamic>.from(r as Map)).toList();
      return list;
    } catch (e) {
      throw Exception('Data fetch failed: $e');
    }
  }

  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await _client.from(table).insert(data).timeout(const Duration(seconds: 15));
  }

  Future<void> updateRow(
    String table,
    String primaryKeyColumn,
    dynamic primaryKeyValue,
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(table)
        .update(data)
        .eq(primaryKeyColumn, primaryKeyValue as Object)
        .timeout(const Duration(seconds: 15));
  }

  Future<void> deleteRow(
    String table,
    String primaryKeyColumn,
    dynamic primaryKeyValue,
  ) async {
    await _client
        .from(table)
        .delete()
        .eq(primaryKeyColumn, primaryKeyValue as Object)
        .timeout(const Duration(seconds: 15));
  }

  void dispose() {
    _client.dispose();
  }
}
