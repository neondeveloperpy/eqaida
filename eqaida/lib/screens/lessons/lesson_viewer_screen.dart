// lib/screens/lessons/lesson_viewer_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/lessons_repository.dart';
import '../../models/lesson_model.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';

/// Universal lesson screen: renders ANY lesson from LessonsRepository.
class LessonViewerScreen extends StatefulWidget {
  final int lessonId;
  const LessonViewerScreen({super.key, required this.lessonId});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  late final LessonModel? _lesson = LessonsRepository.byId(widget.lessonId);
  int _selectedIndex = -1;
  bool _playingAll = false;
  int _unlockedLesson = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _playingAll = false;
    AudioService.instance.stop();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final unlocked = await AuthService.getUnlockedLesson();
    if (mounted) setState(() => _unlockedLesson = unlocked);
  }

  void _playItem(int index) {
    if (_playingAll) _stopPlayAll();
    setState(() => _selectedIndex = index);
    AudioService.instance.play(_lesson!.items[index].audioFile);
  }

  Future<void> _togglePlayAll() async {
    if (_playingAll) {
      _stopPlayAll();
      return;
    }
    setState(() => _playingAll = true);
    final items = _lesson!.items;
    for (var i = 0; i < items.length; i++) {
      if (!_playingAll || !mounted) return;
      setState(() => _selectedIndex = i);
      await AudioService.instance.playAndWait(items[i].audioFile);
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (mounted) setState(() => _playingAll = false);
  }

  void _stopPlayAll() {
    _playingAll = false;
    AudioService.instance.stop();
    if (mounted) setState(() {});
  }

  Future<void> _takeTest() async {
    final lesson = _lesson!;
    _stopPlayAll();
    await Navigator.pushNamed(
      context,
      lesson.customTestRoute ?? AppRoutes.test,
      arguments: lesson.id,
    );
    _loadProgress();
  }

  void _nextLesson() {
    final next = LessonsRepository.nextAvailableAfter(widget.lessonId);
    final messenger = ScaffoldMessenger.of(context);
    if (next == null) {
      messenger.showSnackBar(const SnackBar(content: Text('More lessons are coming soon!')));
    } else if (next.id > _unlockedLesson) {
      messenger.showSnackBar(
        SnackBar(content: Text('Pass the Lesson ${widget.lessonId} test to unlock Lesson ${next.id}!')),
      );
    } else {
      _stopPlayAll();
      Navigator.pushReplacementNamed(context, AppRoutes.lesson, arguments: next.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final colors = context.appColors;

    if (lesson == null || !lesson.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppConstants.appName)),
        body: Center(
          child: Text(
            lesson == null ? 'Lesson not found' : 'Lesson ${lesson.id} is coming soon!',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: colors.action,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onAction, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Lesson banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.banner,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Text(
                    'Lesson ${lesson.id}: ${lesson.title}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: colors.onBanner),
                  ),
                  if (lesson.arabicTitle.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      lesson.arabicTitle,
                      style: TextStyle(
                        fontFamily: AppConstants.arabicFont,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: colors.onBanner,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Items grid, right-to-left so the first item sits top-right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                    itemCount: lesson.items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = lesson.items[index];
                      final selected = _selectedIndex == index;
                      final scheme = Theme.of(context).colorScheme;
                      return InkWell(
                        onTap: () => _playItem(index),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            color: selected ? scheme.primaryContainer : scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? scheme.primary : scheme.outlineVariant,
                              width: selected ? 2.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      item.symbol,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppConstants.arabicFont,
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.letterColor(context, item.color),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _actionButton(
                      colors,
                      label: 'Take a Test',
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      onPressed: _takeTest,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Tooltip(
                    message: _playingAll ? 'Stop' : 'Play all',
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.action,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: IconButton(
                        onPressed: _togglePlayAll,
                        icon: Icon(
                          _playingAll ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                          color: colors.onAction,
                        ),
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 4,
                    child: _actionButton(
                      colors,
                      label: 'Next Lesson',
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      onPressed: _nextLesson,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    AppColors colors, {
    required String label,
    required Icon icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.action,
        foregroundColor: colors.onAction,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      ),
      icon: icon,
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
    );
  }
}
