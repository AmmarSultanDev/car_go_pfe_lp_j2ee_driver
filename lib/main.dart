import 'package:car_go_pfe_lp_j2ee_driver/firebase_options.dart';
import 'package:car_go_pfe_lp_j2ee_driver/providers/user_provider.dart';
import 'package:car_go_pfe_lp_j2ee_driver/resources/app_colors.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/authentication/signin_screen.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

var status;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  askForPermission();

  runApp(const MainApp());
}

askForPermission() async {
  status = await Permission.locationWhenInUse.status;
  if (status == PermissionStatus.denied) {
    await Permission.locationWhenInUse.request();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
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
            headlineLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
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
            headlineLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headlineMedium:
                TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            headlineSmall: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
          ),
        ),
        themeMode: ThemeMode
            .system, // Automatically select the theme based on the system settings
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong!'),
                );
              } else if (snapshot.hasData) {
                return status == PermissionStatus.granted
                    ? const Dashboard()
                    : const SigninScreen();
              }
              return const SigninScreen();
            }),
      ),
    );
  }
}
