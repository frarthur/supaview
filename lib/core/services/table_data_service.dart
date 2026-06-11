import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supaview/features/tables/domain/entities/column_info.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';

class TableDataService {
  TableDataService({
    required String supabaseUrl,
    required String anonKey,
  }) : _client = SupabaseClient(supabaseUrl, anonKey);

  final SupabaseClient _client;

  Future<List<TableInfo>> fetchTables() async {
    final tablesResponse = await _client
        .from('information_schema.tables')
        .select('table_name, table_schema')
        .eq('table_schema', 'public')
        .eq('table_type', 'BASE TABLE');

    final tableNames = <String>[];
    for (final t in tablesResponse) {
      final name = t['table_name'] as String?;
      if (name != null) tableNames.add(name);
    }

    final columnsResponse = await _client
        .from('information_schema.columns')
        .select(
            'table_name, column_name, data_type, is_nullable, column_default')
        .eq('table_schema', 'public');

    final columnsByTable = <String, List<Map<String, dynamic>>>{};
    for (final c in columnsResponse) {
      final tableName = c['table_name'] as String?;
      if (tableName == null) continue;
      columnsByTable.putIfAbsent(tableName, () => []).add(c);
    }

    final primaryKeys = await _fetchPrimaryKeys();

    final tables = <TableInfo>[];
    for (final name in tableNames) {
      final cols = (columnsByTable[name] ?? []).map((c) {
        return ColumnInfo(
          name: c['column_name'] as String? ?? '',
          dataType: c['data_type'] as String? ?? '',
          isNullable: c['is_nullable'] == 'YES',
          isPrimaryKey: primaryKeys.containsKey(name) &&
              (primaryKeys[name]?.contains(c['column_name']) ?? false),
          defaultValue: c['column_default'] as String?,
        );
      }).toList();

      tables.add(TableInfo(
        name: name,
        schema: 'public',
        columns: cols,
        rowCount: 0,
      ));
    }

    return tables;
  }

  Future<Map<String, Set<String>>> _fetchPrimaryKeys() async {
    final response = await _client
        .from('information_schema.table_constraints')
        .select('table_name, constraint_type')
        .eq('table_schema', 'public')
        .eq('constraint_type', 'PRIMARY KEY');

    final tablesWithPK = <String>{};
    for (final r in response) {
      final name = r['table_name'] as String?;
      if (name != null) tablesWithPK.add(name);
    }

    if (tablesWithPK.isEmpty) return {};

    final keyColumns = await _client
        .from('information_schema.key_column_usage')
        .select('table_name, column_name')
        .eq('table_schema', 'public')
        .inFilter('table_name', tablesWithPK.toList());

    final result = <String, Set<String>>{};
    for (final k in keyColumns) {
      final tableName = k['table_name'] as String?;
      final columnName = k['column_name'] as String?;
      if (tableName != null && columnName != null) {
        result.putIfAbsent(tableName, () => {}).add(columnName);
      }
    }
    return result;
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

    List<dynamic> response;
    if (searchQuery != null && searchColumn != null && orderBy != null) {
      response = await _client
          .from(table)
          .select()
          .ilike(searchColumn, '%$searchQuery%')
          .order(orderBy, ascending: ascending)
          .range(from, to);
    } else if (searchQuery != null && searchColumn != null) {
      response = await _client
          .from(table)
          .select()
          .ilike(searchColumn, '%$searchQuery%')
          .range(from, to);
    } else if (orderBy != null) {
      response = await _client
          .from(table)
          .select()
          .order(orderBy, ascending: ascending)
          .range(from, to);
    } else {
      response = await _client
          .from(table)
          .select()
          .range(from, to);
    }

    return response.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }

  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await _client.from(table).insert(data);
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
        .eq(primaryKeyColumn, primaryKeyValue as Object);
  }

  Future<void> deleteRow(
    String table,
    String primaryKeyColumn,
    dynamic primaryKeyValue,
  ) async {
    await _client
        .from(table)
        .delete()
        .eq(primaryKeyColumn, primaryKeyValue as Object);
  }

  void dispose() {
    _client.dispose();
  }
}
