import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supaview/features/tables/domain/entities/column_info.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';

class TableDataService {
  TableDataService({
    required String supabaseUrl,
    required String anonKey,
    String? serviceRoleKey,
  })  : _supabaseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _anonKey = anonKey,
        _serviceRoleKey = serviceRoleKey;

  final String _supabaseUrl;
  final String _anonKey;
  final String? _serviceRoleKey;

  String get _key => _serviceRoleKey ?? _anonKey;

  Future<List<TableInfo>> fetchTables() async {
    final tables = await _queryTables();
    if (tables.isEmpty) return [];

    final columns = await _queryColumns();
    final primaryKeys = await _queryPrimaryKeys();

    return tables.map((t) {
      final tableName = t['table_name'] as String;
      final cols = (columns[tableName] ?? []).map((c) {
        return ColumnInfo(
          name: c['column_name'] as String? ?? '',
          dataType: c['data_type'] as String? ?? '',
          isNullable: c['is_nullable'] == 'YES',
          isPrimaryKey:
              primaryKeys[tableName]?.contains(c['column_name']) ?? false,
          defaultValue: c['column_default'] as String?,
        );
      }).toList();

      return TableInfo(name: tableName, schema: 'public', columns: cols, rowCount: 0);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _queryTables() async {
    try {
      final url = Uri.parse('${_supabaseUrl}rest/v1/information_schema.tables')
          .replace(queryParameters: {
        'table_schema': 'eq.public',
        'table_type': 'eq.BASE TABLE',
        'select': 'table_name,table_schema',
      });
      final response = await http
          .get(url, headers: {
            'apikey': _key,
            'Authorization': 'Bearer $_key',
          })
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _queryColumns() async {
    try {
      final url =
          Uri.parse('${_supabaseUrl}rest/v1/information_schema.columns')
              .replace(queryParameters: {
        'table_schema': 'eq.public',
        'select': 'table_name,column_name,data_type,is_nullable,column_default',
      });
      final response = await http
          .get(url, headers: {
            'apikey': _key,
            'Authorization': 'Bearer $_key',
          })
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final rows = (jsonDecode(response.body) as List)
            .cast<Map<String, dynamic>>();
        final result = <String, List<Map<String, dynamic>>>{};
        for (final r in rows) {
          final tableName = r['table_name'] as String?;
          if (tableName == null) continue;
          result.putIfAbsent(tableName, () => []).add(r);
        }
        return result;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, Set<String>>> _queryPrimaryKeys() async {
    try {
      final url = Uri.parse(
              '${_supabaseUrl}rest/v1/information_schema.table_constraints')
          .replace(queryParameters: {
        'table_schema': 'eq.public',
        'constraint_type': 'eq.PRIMARY KEY',
        'select': 'table_name',
      });
      final response = await http
          .get(url, headers: {
            'apikey': _key,
            'Authorization': 'Bearer $_key',
          })
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return {};

      final tablesWithPK = (jsonDecode(response.body) as List)
          .cast<Map<String, dynamic>>()
          .map((r) => r['table_name'] as String?)
          .whereType<String>()
          .toList();

      if (tablesWithPK.isEmpty) return {};

      final keyUrl = Uri.parse(
              '${_supabaseUrl}rest/v1/information_schema.key_column_usage')
          .replace(queryParameters: {
        'table_schema': 'eq.public',
        'table_name': 'in.(${tablesWithPK.join(',')})',
        'select': 'table_name,column_name',
      });
      final keyResponse = await http
          .get(keyUrl, headers: {
            'apikey': _key,
            'Authorization': 'Bearer $_key',
          })
          .timeout(const Duration(seconds: 10));

      if (keyResponse.statusCode != 200) return {};

      final keyRows = (jsonDecode(keyResponse.body) as List)
          .cast<Map<String, dynamic>>();
      final result = <String, Set<String>>{};
      for (final k in keyRows) {
        final tableName = k['table_name'] as String?;
        final columnName = k['column_name'] as String?;
        if (tableName != null && columnName != null) {
          result.putIfAbsent(tableName, () => {}).add(columnName);
        }
      }
      return result;
    } catch (_) {
      return {};
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

      final url = Uri.parse('$_supabaseUrl/rest/v1/$table')
          .replace(queryParameters: params);
      final response = await http
          .get(url, headers: {
            'apikey': _anonKey,
            'Authorization': 'Bearer $_anonKey',
            'Range-Unit': 'items',
            'Prefer': 'count=exact',
          })
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 206) {
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
      Uri.parse('$_supabaseUrl/rest/v1/$table'),
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
    final url = Uri.parse('$_supabaseUrl/rest/v1/$table')
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
    final url = Uri.parse('$_supabaseUrl/rest/v1/$table')
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
