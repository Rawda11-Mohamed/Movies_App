import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/screens/preview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home:  const PreviewScreen(),
    );
  }
}
