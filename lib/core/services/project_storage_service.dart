import 'dart:convert';

import 'package:supaview/core/services/secure_storage_service.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';

class ProjectStorageService {
  ProjectStorageService({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;
  static const _projectsKey = 'saved_projects';
  static const _keysPrefix = 'project_key_';

  Future<List<Project>> loadProjects() async {
    final raw = await _secureStorage.read(key: _projectsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveProjects(List<Project> projects) async {
    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await _secureStorage.write(key: _projectsKey, value: encoded);
  }

  Future<void> saveAnonKey(String projectId, String anonKey) async {
    await _secureStorage.write(
      key: '$_keysPrefix${projectId}_anon',
      value: anonKey,
    );
  }

  Future<String?> readAnonKey(String projectId) async {
    return _secureStorage.read(key: '$_keysPrefix${projectId}_anon');
  }

  Future<void> saveServiceRoleKey(String projectId, String key) async {
    await _secureStorage.write(
      key: '$_keysPrefix${projectId}_service',
      value: key,
    );
  }

  Future<String?> readServiceRoleKey(String projectId) async {
    return _secureStorage.read(key: '$_keysPrefix${projectId}_service');
  }

  Future<void> deleteProjectKeys(String projectId) async {
    await _secureStorage.delete(key: '$_keysPrefix${projectId}_anon');
    await _secureStorage.delete(key: '$_keysPrefix${projectId}_service');
  }
}
