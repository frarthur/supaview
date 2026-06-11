import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/tables/domain/entities/column_info.dart';
import 'package:supaview/features/tables/domain/entities/table_info.dart';
import 'package:supaview/features/tables/presentation/providers/table_providers.dart';

class RowEditorScreen extends ConsumerStatefulWidget {
  const RowEditorScreen({
    required this.project,
    required this.tableInfo,
    this.existingRow,
    super.key,
  });

  final Project project;
  final TableInfo tableInfo;
  final Map<String, dynamic>? existingRow;

  @override
  ConsumerState<RowEditorScreen> createState() => _RowEditorScreenState();
}

class _RowEditorScreenState extends ConsumerState<RowEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  bool get _isEditing => widget.existingRow != null;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final col in widget.tableInfo.columns) {
      final existingValue = widget.existingRow?[col.name];
      _controllers[col.name] = TextEditingController(
        text: existingValue?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = <String, dynamic>{};
    for (final col in widget.tableInfo.columns) {
      if (col.isPrimaryKey && _isEditing) continue;
      final text = _controllers[col.name]?.text ?? '';
      if (text.isEmpty && col.isNullable) continue;
      data[col.name] = _parseValue(text, col);
    }

    try {
      final service = ref.read(tableDataServiceProvider(widget.project));

      if (_isEditing) {
        final pkColumn = widget.tableInfo.primaryKeyColumns.firstOrNull;
        if (pkColumn != null) {
          await service.updateRow(
            widget.tableInfo.name,
            pkColumn.name,
            widget.existingRow![pkColumn.name],
            data,
          );
        }
      } else {
        await service.insertRow(widget.tableInfo.name, data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  dynamic _parseValue(String text, ColumnInfo col) {
    if (text.isEmpty) return null;
    if (col.isNumeric) {
      if (text.contains('.')) return double.tryParse(text);
      return int.tryParse(text);
    }
    if (col.isBoolean) return text.toLowerCase() == 'true';
    return text;
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Row'),
        content: const Text('Are you sure you want to delete this row?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final pkColumn = widget.tableInfo.primaryKeyColumns.firstOrNull;
      if (pkColumn == null) return;

      final service = ref.read(tableDataServiceProvider(widget.project));
      await service.deleteRow(
        widget.tableInfo.name,
        pkColumn.name,
        widget.existingRow![pkColumn.name],
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Row' : 'New Row'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: widget.tableInfo.columns.map((col) {
            final controller = _controllers[col.name]!;
            final isPk = col.isPrimaryKey;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: controller,
                readOnly: isPk && _isEditing,
                decoration: InputDecoration(
                  labelText: col.name,
                  hintText: _getHint(col),
                  helperText: _getHelperText(col),
                  prefixIcon:
                      isPk ? const Icon(Icons.vpn_key, size: 18) : null,
                ),
                keyboardType: _getKeyboardType(col),
                maxLines: col.isJson ? 3 : 1,
                validator: (v) {
                  if (!col.isNullable && (v == null || v.isEmpty)) {
                    return '${col.name} is required';
                  }
                  return null;
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getHint(ColumnInfo col) {
    if (col.isText) return 'Enter text...';
    if (col.isNumeric) return 'Enter a number...';
    if (col.isBoolean) return 'true or false';
    if (col.isDateTime) return 'YYYY-MM-DD HH:mm:ss';
    if (col.isJson) return 'Enter JSON...';
    return '';
  }

  String _getHelperText(ColumnInfo col) {
    final parts = <String>[col.dataType];
    if (col.isNullable) parts.add('nullable');
    if (col.isPrimaryKey) parts.add('primary key');
    if (col.defaultValue != null) parts.add('default: ${col.defaultValue}');
    return parts.join(' · ');
  }

  TextInputType _getKeyboardType(ColumnInfo col) {
    if (col.isNumeric) return TextInputType.number;
    if (col.isText) return TextInputType.text;
    if (col.isDateTime) return TextInputType.datetime;
    if (col.isJson) return TextInputType.multiline;
    return TextInputType.text;
  }
}
