// lib/screens/test/universal_test_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../data/lessons_repository.dart';
import '../../models/lesson_model.dart';
import '../../models/question_model.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/question_generator.dart';

/// Universal testing engine: builds a random quiz from any lesson's items.
class UniversalTestScreen extends StatefulWidget {
  final int lessonId;
  const UniversalTestScreen({super.key, required this.lessonId});

  @override
  State<UniversalTestScreen> createState() => _UniversalTestScreenState();
}

class _UniversalTestScreenState extends State<UniversalTestScreen> {
  late final LessonModel? _lesson = LessonsRepository.byId(widget.lessonId);
  final _generator = QuestionGenerator();

  List<QuestionModel> _questions = [];
  int _index = 0;
  int _correct = 0;
  int? _selected; // option index picked for the current question

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  @override
  void dispose() {
    AudioService.instance.stop();
    super.dispose();
  }

  void _startQuiz() {
    final lesson = _lesson;
    if (lesson == null) return;
    _questions = _generator.generate(lesson);
    _index = 0;
    _correct = 0;
    _selected = null;
    _onQuestionShown();
  }

  QuestionModel get _q => _questions[_index];
  bool get _answered => _selected != null;

  void _onQuestionShown() {
    // Listening questions start playing by themselves.
    if (_questions.isNotEmpty && _q.type == QuestionType.audioToSymbol) {
      AudioService.instance.play(_q.target.audioFile);
    }
  }

  void _choose(int optionIndex) {
    if (_answered) return;
    final right = _q.isCorrect(optionIndex);
    setState(() {
      _selected = optionIndex;
      if (right) _correct++;
    });
    // Always finish by playing the correct sound to reinforce learning.
    AudioService.instance.play(_q.target.audioFile);
  }

  Future<void> _next() async {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _selected = null;
      });
      _onQuestionShown();
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final lesson = _lesson!;
    final percent = (_correct * 100 / _questions.length).round();
    final passed = percent >= lesson.passScore;
    await AuthService.completeLessonTest(lesson.id, percent, passed: passed);
    if (!mounted) return;

    final next = LessonsRepository.byId(lesson.id + 1);
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(passed ? 'Well done! \u{1F389}' : 'Keep practising! \u{1F4AA}'),
        content: Text(
          passed
              ? 'You scored $percent%.'
                  '${next != null ? '\nLesson ${next.id} is now unlocked!' : ''}'
              : 'You scored $percent%. You need ${lesson.passScore}% to unlock the next lesson.\n'
                  'Listen to the letters again and try once more.',
        ),
        actions: [
          if (!passed)
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Try again')),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(passed ? 'Continue' : 'Back to lesson'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (retry == true) {
      setState(_startQuiz);
    } else {
      Navigator.pop(context, passed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    if (lesson == null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: const Center(child: Text('No test available for this lesson yet.')),
      );
    }

    final colors = context.appColors;
    final q = _q;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson ${lesson.id} Assessment'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_index + 1}/${_questions.length}',
                style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_index + (_answered ? 1 : 0)) / _questions.length,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              _promptArea(q),
              const SizedBox(height: 20),
              Expanded(child: _optionsArea(q, colors)),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _answered ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.action,
                    foregroundColor: colors.onAction,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _index + 1 < _questions.length ? 'Next' : 'Finish',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- prompt ------------------------------------------------------------

  Widget _promptArea(QuestionModel q) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    switch (q.type) {
      case QuestionType.visualRecognition:
        return Column(children: [
          Text(q.prompt, style: titleStyle),
          const SizedBox(height: 4),
          Text(q.target.name,
              style: titleStyle?.copyWith(fontSize: 34, color: Theme.of(context).colorScheme.primary)),
        ]);
      case QuestionType.audioToSymbol:
        return Column(children: [
          Text(q.prompt, style: titleStyle),
          const SizedBox(height: 10),
          IconButton.filled(
            iconSize: 40,
            tooltip: 'Play sound again',
            onPressed: () => AudioService.instance.play(q.target.audioFile),
            icon: const Icon(Icons.volume_up),
          ),
        ]);
      case QuestionType.symbolToAudio:
        return Column(children: [
          Text(q.prompt, style: titleStyle),
          Text(
            q.target.symbol,
            style: TextStyle(
              fontFamily: AppConstants.arabicFont,
              fontSize: 84,
              fontWeight: FontWeight.bold,
              color: AppTheme.letterColor(context, q.target.color),
            ),
          ),
        ]);
      case QuestionType.oddOneOut:
        return Text(q.prompt, textAlign: TextAlign.center, style: titleStyle);
    }
  }

  // ---- options -----------------------------------------------------------

  Widget _optionsArea(QuestionModel q, AppColors colors) {
    if (q.type == QuestionType.symbolToAudio) {
      return ListView.separated(
        itemCount: q.options.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _soundTile(q, i, colors),
      );
    }

    final columns = q.options.length > 4 ? 3 : 2;
    return GridView.builder(
      itemCount: q.options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, i) => _letterCard(q, i, colors),
    );
  }

  /// null = not answered yet, true = correct, false = wrong.
  bool? _stateOf(QuestionModel q, int i) {
    if (!_answered) return null;
    if (q.isCorrect(i)) return true;
    if (i == _selected) return false;
    return null;
  }

  Widget _letterCard(QuestionModel q, int i, AppColors colors) {
    final state = _stateOf(q, i);
    final base = q.optionColors[i];
    final borderColor = state == true
        ? colors.success
        : state == false
            ? colors.danger
            : base;

    return InkWell(
      onTap: () => _choose(i),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: (state == null ? base : borderColor).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: state == null ? 2 : 4),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                q.options[i].symbol,
                style: TextStyle(
                  fontFamily: AppConstants.arabicFont,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: base,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _soundTile(QuestionModel q, int i, AppColors colors) {
    final state = _stateOf(q, i);
    final borderColor = state == true
        ? colors.success
        : state == false
            ? colors.danger
            : q.optionColors[i];

    return Container(
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: state == null ? 2 : 4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Listen',
            style: IconButton.styleFrom(backgroundColor: q.optionColors[i]),
            onPressed: () => AudioService.instance.play(q.options[i].audioFile),
            icon: const Icon(Icons.volume_up),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Sound ${i + 1}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          if (state != null)
            Icon(state ? Icons.check_circle : Icons.cancel, color: borderColor),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _answered ? null : () => _choose(i),
            child: const Text('Choose'),
          ),
        ],
      ),
    );
  }
}
