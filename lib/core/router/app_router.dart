import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/screens/add_project_screen.dart';
import 'package:supaview/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:supaview/features/projects/presentation/screens/project_list_screen.dart';

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
          builder: (context, state) => ProjectDetailScreen(
            projectId: state.pathParameters['id']!,
          ),
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

  static void goToAddProject(BuildContext context) {
    context.push('/projects/add');
  }

  static void goToProjectDetail(BuildContext context, String id) {
    context.push('/projects/$id');
  }
}
