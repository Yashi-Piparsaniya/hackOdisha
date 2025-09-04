import 'package:flutter/material.dart';
import 'package:hack_odisha/routes/routes.dart';

import 'app/common/themes/colors.dart';
import 'app/common/themes/text_field_theme.dart';
import 'app/common/themes/typography.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
