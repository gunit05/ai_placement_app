import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ai_skill_onboarding_screen.dart';
import 'admin_dashboard.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../theme/premium_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        final session = data.session;
        if (session == null) return;

        await _handleUserRouting(
          session.user.id,
          session.user.email ?? "",
        );
      },
    );
  }

  Future<void> _handleUserRouting(
    String userId,
    String email,
  ) async {
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
            builder: (_) => AiSkillOnboardingScreen(
              username: email,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              username: email,
            ),
          ),
        );
      }
    }
  }

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login failed"),
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _glow(
              260,
              AppTheme.primary.withOpacity(0.22),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(
              300,
              Colors.blue.withOpacity(0.10),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: 180,
                    width: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Login to continue your AI placement journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  PremiumCard(
                    child: Column(
                      children: [
                        _inputField(
                          controller: emailController,
                          hint: "Enter email",
                          icon: Icons.email_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),
                        _passwordField(isDark),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: PremiumButton(
                            text: loading ? "Loading..." : "Login",
                            onTap: loading ? () {} : login,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: signInWithGoogle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isDark ? Colors.white12 : Colors.black12,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icon/google.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
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
                          ),
                        ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField(bool isDark) {
    return TextField(
      controller: passwordController,
      obscureText: obscure,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: "Enter password",
        prefixIcon: const Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        ),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
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
