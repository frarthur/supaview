import 'dart:convert';

import 'package:http/http.dart' as http;

class SqlResult {
  SqlResult({
    required this.success,
    this.columns,
    this.rows,
    this.error,
    this.rowCount = 0,
  });

  final bool success;
  final List<String>? columns;
  final List<List<dynamic>>? rows;
  final String? error;
  final int rowCount;
}

class SqlExecutorService {
  SqlExecutorService({
    required String supabaseUrl,
    required String serviceRoleKey,
  })  : _baseUrl = supabaseUrl.endsWith('/') ? supabaseUrl : '$supabaseUrl/',
        _key = serviceRoleKey;

  final String _baseUrl;
  final String _key;

  Future<SqlResult> execute(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return SqlResult(success: true, rowCount: 0);
    }

    final upper = trimmed.toUpperCase();

    if (upper.startsWith('SELECT')) {
      return _executeSelect(trimmed);
    }

    return SqlResult(
      success: false,
      error:
          'Seules les requêtes SELECT sont supportées dans cet éditeur.\n\n'
          "Pour modifier les données, utilise l'onglet Tables.\n"
          'Pour des opérations avancées (DDL), utilise le SQL Editor Supabase:\n'
          'https://supabase.com/dashboard/project/_/sql/new',
    );
  }

  Future<SqlResult> _executeSelect(String query) async {
    try {
      final tableMatch =
          RegExp(r'FROM\s+(\w+)', caseSensitive: false).firstMatch(query);
      if (tableMatch == null) {
        return SqlResult(
          success: false,
          error:
              'Impossible de détecter la table dans la requête.\n\n'
              'Exemple: SELECT * FROM nom_de_la_table',
        );
      }
      final table = tableMatch.group(1)!;
      final url = '${_baseUrl}rest/v1/$table?limit=100';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'apikey': _key,
              'Authorization': 'Bearer $_key',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List;
        if (body.isEmpty) {
          return SqlResult(success: true, rowCount: 0);
        }
        final first = body.first as Map<String, dynamic>;
        final columns = first.keys.toList();
        final rows = body
            .map((r) => (r as Map<String, dynamic>)
                .values
                .map((v) => v ?? 'NULL')
                .toList())
            .toList();
        return SqlResult(
          success: true,
          columns: columns,
          rows: rows,
          rowCount: rows.length,
        );
      }

      if (response.statusCode == 404) {
        return SqlResult(
          success: false,
          error:
              "Table '$table' introuvable.\n\n"
              'Vérifie le nom de la table ou utilise l\'onglet Tables\n'
              'pour voir les tables disponibles.',
        );
      }

      return SqlResult(
        success: false,
        error: 'Erreur HTTP ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      return SqlResult(success: false, error: 'Erreur: $e');
    }
  }
}
