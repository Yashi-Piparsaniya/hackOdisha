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
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.accent,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.headline1,
          displayMedium: AppTypography.headline2,
          bodyLarge: AppTypography.bodyText1,
          bodyMedium: AppTypography.bodyText2,
          labelLarge: AppTypography.button,
        ),
        inputDecorationTheme: AppTextFieldTheme.theme,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
