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
        final decoded = jsonDecode(cached.responseJson);
        if (decoded is Map<String, dynamic> && decoded.containsKey('combined')) {
          return WordDefinition.fromStoredJson(decoded['combined'] as Map<String, dynamic>);
        }
        // Legacy cache format (raw API response list)
        if (decoded is List && decoded.isNotEmpty) {
          final def = WordDefinition.fromJson(decoded.first as Map<String, dynamic>);
          final chinese = await _translateWord(normalized);
          final result = def.copyWith(chineseTranslation: chinese);
          await _db.cacheDefinition(normalized, jsonEncode({'combined': result.toJson()}));
          return result;
        }
      } catch (_) {}
    }

    // 2. Fetch English definition from Free Dictionary API
    WordDefinition? definition;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$normalized'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        if (list.isNotEmpty) {
          definition = WordDefinition.fromJson(list.first as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // 3. Fetch Chinese translation
    final chinese = await _translateWord(normalized);

    if (definition != null) {
      definition = definition.copyWith(chineseTranslation: chinese);
    } else if (chinese != null) {
      definition = WordDefinition(
        word: normalized,
        meanings: [],
        chineseTranslation: chinese,
      );
    }

    // 4. Cache combined result
    if (definition != null) {
      await _db.cacheDefinition(normalized, jsonEncode({'combined': definition.toJson()}));
    }

    return definition;
  }

  Future<String?> _translateWord(String word) async {
    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(word)}&langpair=en|zh-CN',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated = data['responseData']?['translatedText'] as String?;
        if (translated != null && translated.isNotEmpty && translated != word) {
          return translated;
        }
      }
    } catch (_) {}
    return null;
  }
}
