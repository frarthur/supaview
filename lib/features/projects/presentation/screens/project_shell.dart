import 'package:flutter/material.dart';
import 'package:supaview/features/authentication/presentation/auth_screen.dart';
import 'package:supaview/features/functions/presentation/functions_screen.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/screens/dashboard_screen.dart';
import 'package:supaview/features/settings/presentation/settings_screen.dart';
import 'package:supaview/features/sql/presentation/screens/sql_editor_screen.dart';
import 'package:supaview/features/storage/presentation/screens/storage_screen.dart';
import 'package:supaview/features/tables/presentation/screens/table_list_screen.dart';

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
      TableListScreen(project: widget.project),
      SqlEditorScreen(project: widget.project),
      StorageScreen(project: widget.project),
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
            onPressed: () => Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) => AuthScreen(project: widget.project),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Edge Functions',
            onPressed: () => Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) => FunctionsScreen(project: widget.project),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(project: widget.project),
              ),
            ),
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

}
