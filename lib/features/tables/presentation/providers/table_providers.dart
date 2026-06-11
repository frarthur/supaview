import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/table_data_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';

final tableDataServiceProvider = Provider.family<TableDataService, Project>(
  (ref, project) {
    final service = TableDataService(
      supabaseUrl: project.supabaseUrl,
      anonKey: project.anonKey,
    );
    ref.onDispose(service.dispose);
    return service;
  },
);

final tableListProvider = FutureProvider.family<List<TableInfo>, Project>(
  (ref, project) async {
    final service = ref.watch(tableDataServiceProvider(project));
    return service.fetchTables();
  },
);

final tableRowsProvider = FutureProvider.family<List<Map<String, dynamic>>, TableQueryParams>(
  (ref, params) async {
    final service = ref.watch(tableDataServiceProvider(params.project));
    return service.fetchRows(
      table: params.table,
      page: params.page,
      pageSize: params.pageSize,
      orderBy: params.orderBy,
      ascending: params.ascending,
      searchQuery: params.searchQuery,
      searchColumn: params.searchColumn,
    );
  },
);

@immutable
class TableQueryParams {
  const TableQueryParams({
    required this.project,
    required this.table,
    this.page = 0,
    this.pageSize = 50,
    this.orderBy,
    this.ascending = true,
    this.searchQuery,
    this.searchColumn,
  });

  final Project project;
  final String table;
  final int page;
  final int pageSize;
  final String? orderBy;
  final bool ascending;
  final String? searchQuery;
  final String? searchColumn;

  @override
  bool operator ==(Object other) =>
      other is TableQueryParams &&
      other.project.id == project.id &&
      other.table == table &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.orderBy == orderBy &&
      other.ascending == ascending &&
      other.searchQuery == searchQuery &&
      other.searchColumn == searchColumn;

  @override
  int get hashCode =>
      Object.hash(project.id, table, page, pageSize, orderBy, ascending, searchQuery, searchColumn);
}
