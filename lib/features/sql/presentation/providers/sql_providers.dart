import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/sql_executor_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

final sqlExecutorServiceProvider = Provider.family<SqlExecutorService?, Project>(
  (ref, project) {
    if (project.serviceRoleKey == null || project.serviceRoleKey!.isEmpty) {
      return null;
    }
    return SqlExecutorService(
      supabaseUrl: project.supabaseUrl,
      serviceRoleKey: project.serviceRoleKey!,
    );
  },
);
