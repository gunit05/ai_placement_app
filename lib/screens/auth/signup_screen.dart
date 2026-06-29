import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire_hub/theme/premium_ui.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscure = true;

  void _show(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> signup() async {
    if (loading) return;

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _show("All fields required");
      return;
    }

    if (!email.contains('@')) {
      _show("Enter valid email");
      return;
    }

    if (password.length < 6) {
      _show("Password must be 6+ chars");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) throw "Signup failed";

      final existing = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        await Supabase.instance.client.from('users').insert({
          'id': user.id,
          'email': email,
          'username': username,
          'role': 'student',
        });
      }

      _show("Account created successfully");

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _show("Signup failed");
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
    usernameController.dispose();
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
                    height: 170,
                    width: 170,
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
                      Icons.app_registration_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Create Account",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Start your HIREHUB journey",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 36),
                  PremiumCard(
                    child: Column(
                      children: [
                        _inputField(
                          controller: usernameController,
                          hint: "Enter username",
                          icon: Icons.person_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),
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
                            text: loading ? "Creating..." : "Create Account",
                            onTap: loading ? () {} : signup,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: signInWithGoogle,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black12,
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
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have account? Login",
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
