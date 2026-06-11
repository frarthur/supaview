import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/utils/debouncer.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';
import 'package:supaview/features/tables/presentation/providers/table_providers.dart';
import 'package:supaview/features/tables/presentation/screens/row_editor_screen.dart';

class TableDataScreen extends ConsumerStatefulWidget {
  const TableDataScreen({
    required this.project,
    required this.tableInfo,
    super.key,
  });

  final Project project;
  final TableInfo tableInfo;

  @override
  ConsumerState<TableDataScreen> createState() => _TableDataScreenState();
}

class _TableDataScreenState extends ConsumerState<TableDataScreen> {
  int _page = 0;
  String? _orderBy;
  bool _ascending = true;
  String? _searchColumn;
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 400));
  final _pageSize = 50;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  String get _tableName => widget.tableInfo.name;

  @override
  Widget build(BuildContext context) {
    final searchColumn =
        _searchColumn ?? widget.tableInfo.columns.firstOrNull?.name;

    final rowsAsync = ref.watch(tableRowsProvider(
      TableQueryParams(
        project: widget.project,
        table: _tableName,
        page: _page,
        pageSize: _pageSize,
        orderBy: _orderBy,
        ascending: _ascending,
        searchQuery:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        searchColumn: searchColumn,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(_tableName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Insert row',
            onPressed: () => _openRowEditor(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tableRowsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context, searchColumn),
          Expanded(
            child: rowsAsync.when(
              data: (rows) => _buildDataTable(context, rows),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, String? searchColumn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) {
                _debouncer(() => setState(() {}));
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: searchColumn,
            items: widget.tableInfo.columns.map((c) {
              return DropdownMenuItem(value: c.name, child: Text(c.name));
            }).toList(),
            onChanged: (v) => setState(() => _searchColumn = v),
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
      BuildContext context, List<Map<String, dynamic>> rows) {
    final columns = widget.tableInfo.columns;

    if (rows.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No matching rows'
              : 'Table is empty',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
          sortColumnIndex: _orderBy != null
              ? columns.indexWhere((c) => c.name == _orderBy)
              : null,
          sortAscending: _ascending,
          columnSpacing: 16,
          headingRowHeight: 44,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 60,
          headingRowColor:
              WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest),
          columns: columns.map((col) {
            return DataColumn(
              label: SizedBox(
                width: 120,
                child: Text(
                  col.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onSort: (index, asc) {
                setState(() {
                  _orderBy = columns[index].name;
                  _ascending = asc;
                });
              },
              tooltip:
                  '${col.dataType}${col.isPrimaryKey ? ' (PK)' : ''}',
            );
          }).toList(),
          rows: List.generate(rows.length, (i) {
            final row = rows[i];
            return DataRow(
              color: WidgetStatePropertyAll(
                i.isEven ? null : theme.colorScheme.surfaceContainerLow,
              ),
              cells: columns.map((col) {
                final value = row[col.name];
                return DataCell(
                  GestureDetector(
                    onDoubleTap: () =>
                        _openRowEditor(context, existingRow: row),
                    child: SizedBox(
                      width: 120,
                      child: Text(
                        _formatValue(value),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _page > 0 ? () => setState(() => _page--) : null,
          ),
          Text('Page ${_page + 1}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _page++),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'NULL';
    if (value is Map || value is List) return value.toString();
    return value.toString();
  }

  void _openRowEditor(BuildContext context,
      {Map<String, dynamic>? existingRow}) {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => RowEditorScreen(
          project: widget.project,
          tableInfo: widget.tableInfo,
          existingRow: existingRow,
        ),
      ),
    ).then((_) {
      if (mounted) ref.invalidate(tableRowsProvider);
    });
  }
}
