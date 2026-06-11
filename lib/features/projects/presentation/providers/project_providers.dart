import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supaview/core/services/project_storage_service.dart';
import 'package:supaview/core/services/secure_storage_service.dart';
import 'package:supaview/features/projects/data/repositories/project_repository_impl.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/domain/repositories/project_repository.dart';

final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

final projectStorageServiceProvider = Provider(
  (ref) => ProjectStorageService(
    secureStorage: ref.watch(secureStorageServiceProvider),
  ),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepositoryImpl(
    storageService: ref.watch(projectStorageServiceProvider),
  ),
);

final projectListProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjects();
});

final projectProvider = FutureProvider.family<Project, String>(
  (ref, id) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getProject(id);
  },
);
