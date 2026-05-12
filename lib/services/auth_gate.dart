import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';


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
      final user =
          Supabase.instance.client.auth.currentUser;

      final prefs =
          await SharedPreferences.getInstance();

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

        if (!canCheck || !supported) {
          _goLogin();
          return;
        }

        final authenticated =
            await auth.authenticate(
          localizedReason:
              "Unlock with Face ID / Fingerprint",
          options:
              const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!authenticated) {
          _goLogin();
          return;
        }
      }

      _goHome(user.email ?? "User");
    } catch (e) {
      debugPrint("AUTH GATE ERROR: $e");
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
      backgroundColor: const Color(0xff040B2D),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -80,
            child: glow(
              240,
              Colors.deepPurple.withOpacity(0.22),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -90,
            child: glow(
              280,
              Colors.purpleAccent.withOpacity(0.18),
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
                      padding:
                          const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            const LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.pinkAccent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .deepPurple
                                .withOpacity(
                              0.25 +
                                  glowController
                                          .value *
                                      0.35,
                            ),
                            blurRadius: 35,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Securing Your Session",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
                        color:
                            Colors.deepPurpleAccent,
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

  Widget glow(double size, Color color) {
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