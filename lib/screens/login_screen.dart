import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'ai_skill_onboarding_screen.dart';
import 'admin_dashboard.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();

  bool loading = false;
  bool obscure = true;

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _forceLogout();

    _authSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session == null) return;

      final user = session.user;
      final email = user.email ?? "";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUser', email);

      await _handleUserRouting(user.id, email);
    });
  }

  Future<void> _forceLogout() async {
    await Supabase.instance.client.auth.signOut();
  }

  //  BIOMETRIC LOGIN
  Future<void> authenticateWithBiometric() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;

      if (!canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric not available")),
        );
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Login using Face ID / Fingerprint',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        login();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleUserRouting(String userId, String email) async {
    var dataUser = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (dataUser == null) {
      await Supabase.instance.client.from('users').insert({
        'id': userId,
        'email': email,
        'username': email.split('@')[0],
        'role': 'student',
      });

      dataUser = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
    }

    final role = dataUser['role'];

    final skillData = await Supabase.instance.client
        .from('user_skills')
        .select()
        .eq('username', email)
        .maybeSingle();

    if (!mounted) return;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboard(username: email),
        ),
      );
    } else {
      if (skillData == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AiSkillOnboardingScreen(username: email),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(username: email),
          ),
        );
      }
    }
  }

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = res.user;
      if (user == null) throw "User not found";

      final email = user.email ?? "";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUser', email);

      await _handleUserRouting(user.id, email);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  //  GOOGLE LOGIN
  Future<void> signInWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      body: Stack(
        children: [
          // =========================
          // BACKGROUND GLOW
          // =========================

          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.25),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.18),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // =========================
                  // APP LOGO
                  // =========================

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7B2FF7),
                          Color(0xff4A00E0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.45),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Login to continue your AI career journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================
                  // LOGIN CARD
                  // =========================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // EMAIL

                        TextField(
                          controller: emailController,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter email",
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // PASSWORD

                        TextField(
                          controller: passwordController,
                          obscureText: obscure,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter password",
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white70,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // LOGIN BUTTON

                        GestureDetector(
                          onTap: loading ? null : login,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff7B2FF7),
                                  Color(0xffE940FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.45),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // GOOGLE LOGIN

                        GestureDetector(
                          onTap: signInWithGoogle,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://cdn-icons-png.flaticon.com/512/281/281764.png',
                                  height: 22,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // FACE ID

                        GestureDetector(
                          onTap: authenticateWithBiometric,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white12,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  color: Colors.cyanAccent,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Login with Face ID",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // SIGNUP

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create new account",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),

                        // FORGOT PASSWORD

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
