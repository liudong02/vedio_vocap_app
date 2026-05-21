import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/word_definition.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../../services/dictionary_service.dart';
import '../../services/screenshot_service.dart';

class WordPopup extends ConsumerStatefulWidget {
  final String word;
  final String context;
  final String videoId;
  final int videoPositionMs;

  const WordPopup({
    super.key,
    required this.word,
    required this.context,
    required this.videoId,
    required this.videoPositionMs,
  });

  @override
  ConsumerState<WordPopup> createState() => _WordPopupState();
}

class _WordPopupState extends ConsumerState<WordPopup> {
  WordDefinition? _definition;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _alreadySaved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDefinition();
    _checkIfSaved();
  }

  Future<void> _loadDefinition() async {
    final def = await ref.read(dictionaryServiceProvider).lookup(widget.word);
    if (mounted) {
      setState(() {
        _definition = def;
        _isLoading = false;
        _error = def == null ? '未找到"${widget.word}"的释义' : null;
      });
    }
  }

  Future<void> _checkIfSaved() async {
    final exists =
        await ref.read(wordRepositoryProvider).wordExists(widget.word);
    if (mounted) setState(() => _alreadySaved = exists);
  }

  Future<void> _saveWord() async {
    if (_definition == null || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final video =
          await ref.read(videoRepositoryProvider).getVideo(widget.videoId);
      if (video == null) return;

      // Capture screenshot
      final screenshotPath = await ref
          .read(screenshotServiceProvider)
          .captureAndSave(
            videoPath: video.filePath,
            position: Duration(milliseconds: widget.videoPositionMs),
            wordId: widget.word,
          );

      await ref.read(wordRepositoryProvider).saveWord(
            word: widget.word,
            definition: _definition!,
            context: widget.context,
            videoId: widget.videoId,
            videoTitle: video.title,
            videoPositionMs: widget.videoPositionMs,
            screenshotPath: screenshotPath,
          );

      if (mounted) {
        setState(() {
          _alreadySaved = true;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${widget.word}" 已收录'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Word + phonetic
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.word,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  if (_definition?.phonetic != null)
                    Text(
                      _definition!.phonetic!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
              // Chinese translation
              if (_definition?.chineseTranslation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _definition!.chineseTranslation!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              const SizedBox(height: 4),

              // Context sentence
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '"${widget.context}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blueGrey[700],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // Definitions
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : _buildDefinitions(controller),
              ),

              const SizedBox(height: 12),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _alreadySaved ? null : _saveWord,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Icon(_alreadySaved ? Icons.check : Icons.bookmark_add),
                  label: Text(_alreadySaved ? '已收录' : '收录单词'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefinitions(ScrollController controller) {
    final def = _definition!;
    if (def.meanings.isEmpty) {
      return const Center(child: Text('暂无详细释义'));
    }
    return ListView(
      controller: controller,
      children: [
        for (final meaning in def.meanings) ...[
          Chip(
            label: Text(_translatePartOfSpeech(meaning.partOfSpeech)),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 12,
            ),
          ),
          for (int i = 0; i < meaning.definitions.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ${meaning.definitions[i].definition}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (meaning.definitions[i].example != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 8),
                      child: Text(
                        '例: ${meaning.definitions[i].example}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  String _translatePartOfSpeech(String pos) {
    const map = {
      'noun': '名词',
      'verb': '动词',
      'adjective': '形容词',
      'adverb': '副词',
      'pronoun': '代词',
      'preposition': '介词',
      'conjunction': '连词',
      'interjection': '感叹词',
      'determiner': '限定词',
      'exclamation': '感叹词',
    };
    return map[pos.toLowerCase()] ?? pos;
  }
}
