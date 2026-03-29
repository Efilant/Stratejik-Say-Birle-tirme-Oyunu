import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';
import 'utils/color_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const double borderRadiusValue = 12.0;

    return MaterialApp(
      title: 'Stratejik Sayı Birleştirme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.background,
          surface: AppColors.card,
          onSurface: AppColors.foreground,
          secondary: AppColors.border,
          outline: AppColors.border,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: AppColors.foreground, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: AppColors.foreground),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusValue),
          ),
          color: AppColors.card,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusValue),
          ),
        ),
      ),
      home: const GameScreen(),
    );
  }
}
