import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

      _show("Account created 🎉");

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _show("Error: $e");
    }

    if (mounted) setState(() => loading = false);
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
                  const SizedBox(height: 35),

                  // =========================
                  // APP ICON
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
                      Icons.app_registration_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Create Account 🚀",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Start your AI career journey today",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================
                  // SIGNUP CARD
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
                        // USERNAME

                        TextField(
                          controller: usernameController,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter username",
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
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

                        // CREATE ACCOUNT BUTTON

                        GestureDetector(
                          onTap: loading ? null : signup,
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
                                      "Create Account",
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

                        const SizedBox(height: 15),

                        // LOGIN BUTTON

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have account? Login",
                            style: TextStyle(
                              color: Colors.white70,
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
