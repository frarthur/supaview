import 'package:flutter/material.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

class FunctionsScreen extends StatelessWidget {
  const FunctionsScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edge Functions')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.code,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'Edge Functions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
