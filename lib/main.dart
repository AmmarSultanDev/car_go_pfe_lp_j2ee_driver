import 'package:car_go_pfe_lp_j2ee_driver/firebase_options.dart';
import 'package:car_go_pfe_lp_j2ee_driver/resources/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.lightPrimary,
        scaffoldBackgroundColor: AppColors.lightSurface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimary,
          onPrimary: AppColors.lightOnPrimary,
          secondary: AppColors.lightSecondary,
          onSecondary: AppColors.lightOnSecondary,
        ),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headlineMedium:
              TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          headlineSmall: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: AppColors.darkPrimary,
        canvasColor: AppColors.darkBackground,
        scaffoldBackgroundColor: AppColors.darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkOnPrimary,
          secondary: AppColors.darkSecondary,
          onSecondary: AppColors.darkOnSecondary,
        ),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headlineMedium:
              TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          headlineSmall: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
        ),
      ),
      themeMode: ThemeMode
          .system, // Automatically select the theme based on the system settings
      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
