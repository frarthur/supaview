import 'package:go_router/go_router.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/screens/add_project_screen.dart';
import 'package:supaview/features/projects/presentation/screens/project_list_screen.dart';
import 'package:supaview/features/projects/presentation/screens/project_shell.dart';

class AppRouter {
  AppRouter();

  GoRouter config() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ProjectListScreen(),
        ),
        GoRoute(
          path: '/projects/add',
          builder: (context, state) => const AddProjectScreen(),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (context, state) {
            final project = state.extra as Project?;
            if (project == null) {
              return const ProjectListScreen();
            }
            return ProjectShell(project: project);
          },
        ),
        GoRoute(
          path: '/projects/:id/edit',
          builder: (context, state) {
            final project = state.extra as Project?;
            return AddProjectScreen(project: project);
          },
        ),
      ],
    );
  }
}
