import 'package:flutter/material.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    required this.onTap,
    super.key,
  });

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: project.color.isNotEmpty
              ? Color(int.parse(project.color.replaceFirst('#', '0xFF')))
              : colorScheme.primaryContainer,
          child: Text(
            project.name.isNotEmpty
                ? project.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: project.color.isNotEmpty
                  ? Colors.white
                  : colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(project.name),
        subtitle: Text(
          project.supabaseUrl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
