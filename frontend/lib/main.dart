import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hack_odisha/routes/routes.dart';
import 'app/common/themes/colors.dart';
import 'app/common/themes/text_field_theme.dart';
import 'app/common/themes/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwasthAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.headline1,
          displayMedium: AppTypography.headline2,
          displaySmall: AppTypography.headline3,
          headlineMedium: AppTypography.headline4,
          bodyLarge: AppTypography.bodyText1,
          bodyMedium: AppTypography.bodyText2,

          bodySmall: AppTypography.bodyText3,
          labelLarge: AppTypography.button,
          labelMedium: AppTypography.buttonSmall,
          labelSmall: AppTypography.caption,

        ),
        inputDecorationTheme: AppTextFieldTheme.theme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.button,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
