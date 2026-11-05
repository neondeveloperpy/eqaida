// lib/core/theme/theme_toggle_button.dart
import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// Round icon button that switches between light and dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.instance.isDark(context);
    return IconButton(
      tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => ThemeController.instance.toggle(context),
    );
  }
}
