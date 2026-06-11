import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/sql/presentation/providers/sql_providers.dart';

class SqlEditorScreen extends ConsumerStatefulWidget {
  const SqlEditorScreen({super.key, required this.project});

  final Project project;

  @override
  ConsumerState<SqlEditorScreen> createState() => _SqlEditorScreenState();
}

class _SqlEditorScreenState extends ConsumerState<SqlEditorScreen> {
  final _controller = TextEditingController();
  bool _isExecuting = false;
  dynamic _result;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _execute() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isExecuting = true;
      _result = null;
      _error = null;
    });

    final service = ref.read(sqlExecutorServiceProvider(widget.project));
    if (service == null) {
      setState(() {
        _error = 'Service Role Key requise.';
        _isExecuting = false;
      });
      return;
    }

    final result = await service.execute(query);

    setState(() {
      _isExecuting = false;
      result.success ? _result = result : _error = result.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Editor'),
        actions: [
          FilledButton.tonalIcon(
            onPressed: _isExecuting ? null : _execute,
            icon: _isExecuting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: const Text('Run'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEditor(theme),
          const Divider(height: 1),
          Expanded(child: _buildResults(theme)),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
      ),
      child: TextField(
        controller: _controller,
        maxLines: null,
        minLines: 3,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        decoration: InputDecoration(
          hintText: 'SELECT * FROM table_name LIMIT 10;',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_isExecuting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text('Result', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              _error!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    if (_result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, size: 48,
                color: theme.colorScheme.primary.withAlpha(80)),
            const SizedBox(height: 12),
            Text('Write a SELECT query', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'SELECT * FROM table_name LIMIT 10;',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final sqlResult = _result as dynamic;
    final columns = (sqlResult as dynamic).columns as List<String>?;
    final rows = (sqlResult as dynamic).rows as List<List<dynamic>>?;

    if (columns == null || rows == null) {
      return Center(
        child: Text(
          (sqlResult as dynamic).error as String? ?? 'Done (0 rows).',
        ),
      );
    }

    if (rows.isEmpty) {
      return const Center(child: Text('Query returned 0 rows.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${rows.length} row(s)',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 48,
                headingRowColor: WidgetStatePropertyAll(
                  theme.colorScheme.surfaceContainerHighest,
                ),
                columns: columns
                    .map((c) => DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text(c,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium),
                          ),
                        ))
                    .toList(),
                rows: rows.map((row) {
                  return DataRow(
                    color: WidgetStatePropertyAll(
                      rows.indexOf(row).isEven
                          ? null
                          : theme.colorScheme.surfaceContainerLow,
                    ),
                    cells: row.map((cell) {
                      return DataCell(SizedBox(
                        width: 120,
                        child: Text(
                          cell?.toString() ?? 'NULL',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
