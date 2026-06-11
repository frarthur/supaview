import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/tables/presentation/providers/table_providers.dart';
import 'package:supaview/features/tables/presentation/screens/table_data_screen.dart';

class TableListScreen extends ConsumerWidget {
  const TableListScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tableListProvider(project));

    return tablesAsync.when(
      data: (tables) {
        if (tables.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_chart_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withAlpha(80),
                ),
                const SizedBox(height: 16),
                Text(
                  'No tables found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create tables in your Supabase project',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(tableListProvider(project).future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              final pkColumns = table.primaryKeyColumns;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.table_chart,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(table.name),
                  subtitle: Text(
                    '${table.columns.length} columns${pkColumns.isNotEmpty ? ' · PK: ${pkColumns.map((c) => c.name).join(', ')}' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TableDataScreen(
                          project: project,
                          tableInfo: table,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              const Text('Failed to load tables'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
