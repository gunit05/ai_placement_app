import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';
import 'screens/reset_password_screen.dart';
import 'theme/premium_ui.dart';
import 'theme/theme_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await dotenv.load(fileName: 'assets/.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        ),
        (route) => false,
      );
    }
  });

  runApp(const PlacementApp());
}

class PlacementApp extends StatefulWidget {
  const PlacementApp({super.key});

  @override
  State<PlacementApp> createState() => _PlacementAppState();
}

class _PlacementAppState extends State<PlacementApp> {
  @override
  void initState() {
    super.initState();
    themeController.addListener(_refresh);
  }

  @override
  void dispose() {
    themeController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'HIREHUB',
      themeMode: themeController.themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const SplashScreen(),
    );
  }
}