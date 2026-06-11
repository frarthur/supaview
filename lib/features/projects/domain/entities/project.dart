class Project {
  Project({
    required this.id,
    required this.name,
    required this.supabaseUrl,
    required this.anonKey,
    this.serviceRoleKey,
    this.color,
    this.createdAt,
  });

  final String id;
  final String name;
  final String supabaseUrl;
  final String anonKey;
  final String? serviceRoleKey;
  final String? color;
  final DateTime? createdAt;
}
