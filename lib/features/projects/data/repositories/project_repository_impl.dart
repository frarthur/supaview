import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  @override
  Future<List<Project>> getProjects() async {
    return [];
  }

  @override
  Future<Project> getProject(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveProject(Project project) async {}

  @override
  Future<void> deleteProject(String id) async {}

  @override
  Future<bool> testConnection(Project project) async {
    return false;
  }
}
