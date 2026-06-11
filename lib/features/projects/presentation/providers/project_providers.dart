import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supaview/features/projects/data/repositories/project_repository_impl.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

final projectRepositoryProvider = Provider((ref) => ProjectRepositoryImpl());

final projectListProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjects();
});
