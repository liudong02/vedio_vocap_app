import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/word_definition.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../../services/dictionary_service.dart';
import '../../services/screenshot_service.dart';
import '../widgets/bottom_sheet_handle.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_icon.dart';

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
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHandle(),

              // Word + phonetic
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.word,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 10),
                  if (_definition?.phonetic != null)
                    Text(
                      _definition!.phonetic!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                ],
              ),

              // Chinese translation with gradient
              if (_definition?.chineseTranslation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: GradientText(
                    text: _definition!.chineseTranslation!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Context sentence
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x0D7B61FF),
                  border: Border.all(color: const Color(0x1A7B61FF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${widget.context}"',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Definitions
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Text(_error!,
                                style: TextStyle(color: AppColors.textSecondary)))
                        : _buildDefinitions(controller),
              ),

              const SizedBox(height: 16),

              // Save button
              if (_alreadySaved)
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded,
                          color: AppColors.textTertiary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '已收录',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: '收录单词',
                    icon: Icons.bookmark_add_rounded,
                    isLoading: _isSaving,
                    onPressed: _saveWord,
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
      return const Center(
          child: Text('暂无详细释义',
              style: TextStyle(color: AppColors.textTertiary)));
    }
    return ListView(
      controller: controller,
      padding: EdgeInsets.zero,
      children: [
        for (final meaning in def.meanings) ...[
          Chip(
            label: Text(_translatePartOfSpeech(meaning.partOfSpeech)),
          ),
          for (int i = 0; i < meaning.definitions.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ${meaning.definitions[i].definition}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (meaning.definitions[i].example != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        '例: ${meaning.definitions[i].example}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
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
