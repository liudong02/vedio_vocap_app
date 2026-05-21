import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import '../data/models/word_definition.dart';

final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  return DictionaryService(ref.watch(databaseProvider));
});

class DictionaryService {
  final AppDatabase _db;
  static const _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  DictionaryService(this._db);

  Future<WordDefinition?> lookup(String word) async {
    final normalized = word.toLowerCase().trim();
    if (normalized.isEmpty) return null;

    // 1. Check local cache first
    final cached = await _db.getCachedDefinition(normalized);
    if (cached != null) {
      try {
        final list = jsonDecode(cached.responseJson) as List;
        if (list.isNotEmpty) {
          return WordDefinition.fromJson(list.first as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    // 2. Fetch from API
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$normalized'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = response.body;
        await _db.cacheDefinition(normalized, json);
        final list = jsonDecode(json) as List;
        if (list.isNotEmpty) {
          return WordDefinition.fromJson(list.first as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Network error — return null, caller handles gracefully
    }

    return null;
  }
}
