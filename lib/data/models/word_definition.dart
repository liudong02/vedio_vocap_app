class WordDefinition {
  final String word;
  final String? phonetic;
  final List<WordMeaning> meanings;
  final String? audioUrl;

  const WordDefinition({
    required this.word,
    this.phonetic,
    required this.meanings,
    this.audioUrl,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    final phonetics = json['phonetics'] as List? ?? [];
    String? phonetic;
    String? audioUrl;
    for (final p in phonetics) {
      phonetic ??= p['text'] as String?;
      audioUrl ??= (p['audio'] as String?)?.isNotEmpty == true ? p['audio'] : null;
    }

    final meanings = (json['meanings'] as List? ?? [])
        .map((m) => WordMeaning.fromJson(m as Map<String, dynamic>))
        .toList();

    return WordDefinition(
      word: json['word'] as String,
      phonetic: phonetic,
      meanings: meanings,
      audioUrl: audioUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'audioUrl': audioUrl,
        'meanings': meanings.map((m) => m.toJson()).toList(),
      };

  factory WordDefinition.fromStoredJson(Map<String, dynamic> json) {
    return WordDefinition(
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      audioUrl: json['audioUrl'] as String?,
      meanings: (json['meanings'] as List? ?? [])
          .map((m) => WordMeaning.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WordMeaning {
  final String partOfSpeech;
  final List<WordDefinitionEntry> definitions;

  const WordMeaning({required this.partOfSpeech, required this.definitions});

  factory WordMeaning.fromJson(Map<String, dynamic> json) => WordMeaning(
        partOfSpeech: json['partOfSpeech'] as String? ?? '',
        definitions: (json['definitions'] as List? ?? [])
            .take(3)
            .map((d) => WordDefinitionEntry.fromJson(d as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'partOfSpeech': partOfSpeech,
        'definitions': definitions.map((d) => d.toJson()).toList(),
      };
}

class WordDefinitionEntry {
  final String definition;
  final String? example;

  const WordDefinitionEntry({required this.definition, this.example});

  factory WordDefinitionEntry.fromJson(Map<String, dynamic> json) =>
      WordDefinitionEntry(
        definition: json['definition'] as String? ?? '',
        example: json['example'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'definition': definition,
        'example': example,
      };
}
