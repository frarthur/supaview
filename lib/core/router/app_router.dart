import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter();

  GoRouter config() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Projects'),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Add Project'),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => _PlaceholderScreen(
                title: 'Project ${state.pathParameters['id']}',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Settings'),
        ),
      ],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
