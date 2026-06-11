import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supaview/core/services/project_storage_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({required ProjectStorageService storageService})
      : _storageService = storageService;

  final ProjectStorageService _storageService;

  @override
  Future<List<Project>> getProjects() async {
    return _storageService.loadProjects();
  }

  @override
  Future<Project> getProject(String id) async {
    final projects = await _storageService.loadProjects();
    return projects.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> saveProject(Project project) async {
    final projects = await _storageService.loadProjects();
    final index = projects.indexWhere((p) => p.id == project.id);

    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }

    await _storageService.saveProjects(projects);
    await _storageService.saveAnonKey(project.id, project.anonKey);
    if (project.serviceRoleKey != null) {
      await _storageService.saveServiceRoleKey(
        project.id,
        project.serviceRoleKey!,
      );
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    final projects = await _storageService.loadProjects();
    projects.removeWhere((p) => p.id == id);
    await _storageService.saveProjects(projects);
    await _storageService.deleteProjectKeys(id);
  }

  @override
  Future<bool> testConnection(Project project) async {
    try {
      final client = SupabaseClient(project.supabaseUrl, project.anonKey);
      await client.from('_test_connection').select().limit(1);
      return true;
    } catch (_) {
      try {
        final client = SupabaseClient(project.supabaseUrl, project.anonKey);
        await client.from('_test_connection').select().limit(0);
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
