import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire_hub/theme/premium_ui.dart';

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
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
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
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://reset-password',
      );

      _show("Reset link sent! Check your email");
    } catch (_) {
      _show("Failed to send reset link");
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return PremiumScreen(
      title: "Forgot Password",
      subtitle: "Recover your account securely",
      icon: Icons.lock_reset_rounded,
      scrollable: true,
      child: PremiumCard(
        child: Column(
          children: [
            Container(
              height: 120,
              width: 120,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.aiGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Reset Password",
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Enter your registered email to receive a password reset link.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Enter email",
                prefixIcon:
                    const Icon(Icons.email_rounded),
                filled: true,
                fillColor: isDark
                    ? Colors.white10
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: loading
                    ? "Sending..."
                    : "Send Reset Link",
                icon: Icons.send_rounded,
                onTap:
                    loading ? () {} : sendResetLink,
              ),
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark
                    ? Colors.white70
                    : Colors.black54,
              ),
              label: Text(
                "Back to Login",
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}