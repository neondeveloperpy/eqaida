// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../data/lessons_repository.dart';
import '../../models/lesson_model.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _unlockedLesson = 1;
  Map<int, int> _scores = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = await AuthService.loadUser();
    if (!mounted || user == null) return;
    setState(() {
      _unlockedLesson = user.highestUnlockedLesson;
      _scores = user.testScores;
    });
  }

  void _openLesson(LessonModel lesson) {
    if (!lesson.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lesson ${lesson.id} is coming soon!')),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.lesson, arguments: lesson.id)
        .then((_) => _loadProgress());
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final current = LessonsRepository.currentFor(_unlockedLesson);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppConstants.homeImage),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      AppConstants.appName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButtonTheme(
                          data: IconButtonThemeData(
                            style: IconButton.styleFrom(foregroundColor: Colors.black87),
                          ),
                          child: const ThemeToggleButton(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          tooltip: 'Log out',
                          icon: const Icon(Icons.logout, color: Colors.black87, size: 20),
                          onPressed: _logout,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _openLesson(current),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.lessonCard,
                            foregroundColor: colors.onLessonCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Continue Lesson',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text('Lesson ${current.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  for (final lesson in LessonsRepository.all) _lessonCard(lesson, colors),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _lessonCard(LessonModel lesson, AppColors colors) {
    final unlocked = lesson.id <= _unlockedLesson;
    final playable = unlocked && lesson.isAvailable;
    final score = _scores[lesson.id];
    final fg = playable ? colors.onLessonCard : colors.onLessonCard.withValues(alpha: 0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: unlocked
            ? () => _openLesson(lesson)
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please pass the Lesson ${lesson.id - 1} test to unlock this lesson!'),
                    backgroundColor: colors.danger,
                  ),
                ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: playable ? colors.lessonCard : colors.lessonCardLocked,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lesson ${lesson.id}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fg)),
                    Text(
                      lesson.isAvailable ? lesson.title : '${lesson.title} \u2022 Coming soon',
                      style: TextStyle(fontSize: 13, color: fg),
                    ),
                  ],
                ),
              ),
              if (score != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Chip(
                    label: Text('$score%'),
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                  ),
                ),
              Icon(
                !unlocked
                    ? Icons.lock
                    : (lesson.isAvailable ? Icons.arrow_forward_ios : Icons.hourglass_empty),
                color: fg,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
