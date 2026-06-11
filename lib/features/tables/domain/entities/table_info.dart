import 'package:supaview/features/tables/domain/entities/column_info.dart';

class TableInfo {
  TableInfo({
    required this.name,
    required this.schema,
    required this.columns,
    required this.rowCount,
  });

  final String name;
  final String schema;
  final List<ColumnInfo> columns;
  final int rowCount;

  List<ColumnInfo> get primaryKeyColumns =>
      columns.where((c) => c.isPrimaryKey).toList();
}
