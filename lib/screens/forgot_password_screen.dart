import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  bool loading = false;

  void _show(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> sendResetLink() async {
    if (loading) return;

    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _show("Enter valid email");
      return;
    }

    setState(() => loading = true);

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(
        email,
        redirectTo:
            'io.supabase.flutter://reset-password',
      );

      _show("Reset link sent! Check email 📩");

    } catch (e) {
      _show("Error: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "Forgot Password",
      subtitle:
          "Reset your account password securely",
      icon: Icons.lock_reset,
      scrollable: true,
      child: PremiumCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.deepOrange,
                    Colors.purple,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.orange.withOpacity(0.35),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter your registered email to receive a reset password link.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
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
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            PremiumButton(
              text: loading
                  ? "Sending..."
                  : "Send Reset Link",
              icon: Icons.send,
              onTap:
                  loading ? () {} : sendResetLink,
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
              ),
              label: const Text(
                "Back to Login",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}