import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../theme/premium_ui.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _checkAuth();
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      final prefs = await SharedPreferences.getInstance();

      final faceLockEnabled =
          prefs.getBool('face_lock') ?? false;

      if (user == null) {
        _goLogin();
        return;
      }

      if (faceLockEnabled) {
        final canCheck =
            await auth.canCheckBiometrics;

        final supported =
            await auth.isDeviceSupported();

        final available =
            await auth.getAvailableBiometrics();

        if (!canCheck ||
            !supported ||
            available.isEmpty) {
          _goLogin();
          return;
        }

        final authenticated =
            await auth.authenticate(
          localizedReason:
              "Authenticate to continue",
          options:
              const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (!authenticated) {
          _goLogin();
          return;
        }
      }

      _goHome(user.email ?? "User");
    } catch (_) {
      _goLogin();
    }
  }

  void _goLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _goHome(String email) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          username: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -80,
            child: _glow(
              240,
              AppTheme.primary.withOpacity(0.22),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -90,
            child: _glow(
              280,
              Colors.blue.withOpacity(0.12),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: glowController,
              builder: (_, __) {
                return Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary
                                .withOpacity(
                              0.25 +
                                  glowController.value *
                                      0.25,
                            ),
                            blurRadius: 35,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/ai_robot.png',
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Securing Session",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Checking authentication & biometric access...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const SizedBox(
                      width: 36,
                      height: 36,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}