import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/app/app_dependencies.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/register_screen.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/home/home_cubit.dart';
import 'package:my_project/state/profile/profile_cubit.dart';
import 'package:my_project/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final dependencies = await AppDependencies.create();
  final hasSession = await dependencies.authService.hasActiveSession();

  runApp(
    MyApp(
      dependencies: dependencies,
      initialRoute: hasSession ? '/home' : '/login',
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.dependencies,
    required this.initialRoute,
    super.key,
  });

  final AppDependencies dependencies;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => BlocProvider(
              create: (_) => AuthCubit(
                authService: dependencies.authService,
                connectivityService: dependencies.connectivityService,
              ),
              child: const LoginScreen(),
            ),
        '/register': (_) => BlocProvider(
              create: (_) => AuthCubit(authService: dependencies.authService),
              child: const RegisterScreen(),
            ),
        '/home': (_) => BlocProvider(
              create: (_) => HomeCubit(
                authService: dependencies.authService,
                connectivityService: dependencies.connectivityService,
                healthRecordService: dependencies.healthRecordService,
                mqttService: dependencies.mqttService,
              )..load(),
              child: const HomeScreen(),
            ),
        '/profile': (_) => BlocProvider(
              create: (_) => ProfileCubit(
                authService: dependencies.authService,
                healthRecordService: dependencies.healthRecordService,
              )..loadUser(),
              child: const ProfileScreen(),
            ),
      },
    );
  }
}
