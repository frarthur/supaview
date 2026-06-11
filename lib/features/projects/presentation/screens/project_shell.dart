import 'package:flutter/material.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/screens/dashboard_screen.dart';

class ProjectShell extends StatefulWidget {
  const ProjectShell({required this.project, super.key});

  final Project project;

  @override
  State<ProjectShell> createState() => _ProjectShellState();
}

class _ProjectShellState extends State<ProjectShell> {
  int _currentIndex = 0;

  late final List<Widget> _sections;

  @override
  void initState() {
    super.initState();
    _sections = [
      DashboardScreen(project: widget.project),
      const _PlaceholderSection(title: 'Tables', icon: Icons.table_chart),
      const _PlaceholderSection(title: 'SQL Editor', icon: Icons.terminal),
      const _PlaceholderSection(title: 'Storage', icon: Icons.folder),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Authentication',
            onPressed: () => _showComingSoon(context, 'Authentication'),
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Edge Functions',
            onPressed: () => _showComingSoon(context, 'Edge Functions'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _showComingSoon(context, 'Settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _sections,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: 'Tables',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: 'SQL',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Storage',
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(feature),
        content: Text('$feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
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
    );
  }
}
