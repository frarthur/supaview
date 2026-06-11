import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supaview/core/router/app_router.dart';
import 'package:supaview/theme/app_theme.dart';

class SupaViewApp extends ConsumerWidget {
  const SupaViewApp({super.key});

  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SupaView',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _appRouter.config(),
    );
  }
}
