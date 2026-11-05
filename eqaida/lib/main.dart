// lib/main.dart
import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/lessons/lesson_viewer_screen.dart';
import 'screens/test/universal_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  runApp(const QaidaApp());
}

class QaidaApp extends StatelessWidget {
  const QaidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) => MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeController.instance.mode,
        home: const AuthGate(),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget? page;
    final lessonId = settings.arguments is int ? settings.arguments as int : null;

    switch (settings.name) {
      case AppRoutes.auth:
        page = const AuthScreen();
      case AppRoutes.home:
        page = const HomeScreen();
      case AppRoutes.lesson:
        if (lessonId != null) page = LessonViewerScreen(lessonId: lessonId);
      case AppRoutes.test:
        if (lessonId != null) page = UniversalTestScreen(lessonId: lessonId);
    }
    if (page == null) return null;
    return MaterialPageRoute(settings: settings, builder: (_) => page!);
  }
}
