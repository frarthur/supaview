import 'package:supaview/features/projects/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<Project> getProject(String id);
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id);
  Future<bool> testConnection(Project project);
}
