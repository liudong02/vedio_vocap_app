import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  static const _youdaoUrl = 'https://dict.youdao.com/jsonapi_s?doctype=json&jsonversion=4&le=en';
  static const _freeDictUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  DictionaryService(this._db);

  Future<WordDefinition?> lookup(String word) async {
    final normalized = word.toLowerCase().trim();
    if (normalized.isEmpty) return null;

    final cached = await _db.getCachedDefinition(normalized);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached.responseJson);
        if (decoded is Map<String, dynamic> && decoded.containsKey('combined')) {
          return WordDefinition.fromStoredJson(decoded['combined'] as Map<String, dynamic>);
        }
        if (decoded is List && decoded.isNotEmpty) {
          final def = WordDefinition.fromJson(decoded.first as Map<String, dynamic>);
          return def;
        }
      } catch (_) {}
    }

    // Primary: Youdao Dictionary API
    WordDefinition? definition = await _lookupYoudao(normalized);

    // Fallback: Free Dictionary API
    if (definition == null) {
      definition = await _lookupFreeDictionary(normalized);
    }

    if (definition != null) {
      await _db.cacheDefinition(
          normalized, jsonEncode({'combined': definition.toJson()}));
    }

    return definition;
  }

  Future<WordDefinition?> _lookupYoudao(String word) async {
    try {
      final response = await http
          .get(Uri.parse('$_youdaoUrl&q=${Uri.encodeComponent(word)}'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseYoudaoResponse(word, data);
    } catch (e) {
      debugPrint('[Dictionary] Youdao error: $e');
      return null;
    }
  }

  WordDefinition? _parseYoudaoResponse(String word, Map<String, dynamic> data) {
    final ecRaw = data['ec'];
    if (ecRaw == null || ecRaw is! Map<String, dynamic>) return null;
    final ec = ecRaw;

    final wordField = ec['word'];
    Map<String, dynamic>? ecWord;
    if (wordField is Map<String, dynamic>) {
      ecWord = wordField;
    } else if (wordField is List && wordField.isNotEmpty) {
      ecWord = wordField.first as Map<String, dynamic>?;
    }
    if (ecWord == null) return null;

    // Phonetic
    final ukPhone = ecWord['ukphone'] as String?;
    final usPhone = ecWord['usphone'] as String?;
    final phonetic = ukPhone != null ? '/$ukPhone/' : (usPhone != null ? '/$usPhone/' : null);

    // Chinese translation from ec.word.trs
    final ecTrs = ecWord['trs'] as List? ?? [];
    final chineseParts = <String>[];
    final meanings = <WordMeaning>[];

    for (final tr in ecTrs) {
      final pos = tr['pos'] as String? ?? '';
      final tran = tr['tran'] as String? ?? '';
      if (tran.isNotEmpty) {
        chineseParts.add('${pos.isNotEmpty ? "$pos " : ""}$tran');
      }
    }

    // English definitions from ee field
    final ee = data['ee'] as Map<String, dynamic>?;
    final eeWord = ee?['word'] as Map<String, dynamic>?;
    final eeTrs = eeWord?['trs'] as List?;

    if (eeTrs != null && eeTrs.isNotEmpty) {
      for (final tr in eeTrs) {
        final pos = tr['pos'] as String? ?? '';
        final trList = tr['tr'] as List? ?? [];
        final defs = <WordDefinitionEntry>[];
        for (final item in trList.take(3)) {
          final tran = item['tran'] as String? ?? '';
          final examples = item['examples'] as List?;
          final example = examples != null && examples.isNotEmpty
              ? examples.first as String
              : null;
          if (tran.isNotEmpty) {
            defs.add(WordDefinitionEntry(definition: tran, example: example));
          }
        }
        if (defs.isNotEmpty) {
          meanings.add(WordMeaning(
            partOfSpeech: pos.replaceAll('.', '').trim(),
            definitions: defs,
          ));
        }
      }
    } else {
      // Fallback: build meanings from ec Chinese definitions
      for (final tr in ecTrs) {
        final pos = (tr['pos'] as String? ?? '').replaceAll('.', '').trim();
        final tran = tr['tran'] as String? ?? '';
        if (tran.isNotEmpty) {
          meanings.add(WordMeaning(
            partOfSpeech: pos,
            definitions: [WordDefinitionEntry(definition: tran)],
          ));
        }
      }
    }

    final chinese = chineseParts.isNotEmpty ? chineseParts.join('；') : null;

    if (meanings.isEmpty && chinese == null) return null;

    return WordDefinition(
      word: word,
      phonetic: phonetic,
      meanings: meanings,
      chineseTranslation: chinese,
    );
  }

  Future<WordDefinition?> _lookupFreeDictionary(String word) async {
    try {
      final response = await http
          .get(Uri.parse('$_freeDictUrl/$word'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        if (list.isNotEmpty) {
          return WordDefinition.fromJson(list.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[Dictionary] FreeDictionary error: $e');
    }
    return null;
  }
}
