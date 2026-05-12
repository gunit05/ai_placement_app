import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/premium_ui.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool loading = false;

  bool obscure1 = true;
  bool obscure2 = true;

  void _show(String msg) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            AppTheme.primary,

        content: Text(msg),
      ),
    );
  }

  Future<void> updatePassword() async {

    if (loading) return;

    final password =
        passwordController.text.trim();

    final confirm =
        confirmController.text.trim();

    if (password.isEmpty ||
        confirm.isEmpty) {

      _show(
          "All fields are required");

      return;
    }

    if (password.length < 6) {

      _show(
          "Password must be at least 6 characters");

      return;
    }

    if (password != confirm) {

      _show(
          "Passwords do not match");

      return;
    }

    setState(() => loading = true);

    try {

      await Supabase.instance.client
          .auth
          .updateUser(
        UserAttributes(
          password: password,
        ),
      );

      if (!mounted) return;

      _show(
          "Password updated successfully ✅");

      Navigator.pop(context);

    } catch (e) {

      _show(
        "Error: ${e.toString()}",
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {

    passwordController.dispose();

    confirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          AppTheme.darkBg,

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

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color: Colors
                    .deepPurple
                    .withOpacity(0.25),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            right: -100,

            child: Container(
              width: 300,
              height: 300,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color: Colors
                    .purpleAccent
                    .withOpacity(0.18),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child:
                  SingleChildScrollView(

                padding:
                    const EdgeInsets
                        .all(22),

                child: Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(24),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white10,

                    borderRadius:
                        BorderRadius
                            .circular(
                                32),

                    border: Border.all(
                      color:
                          Colors.white12,
                    ),

                    boxShadow: [

                      BoxShadow(
                        color: Colors
                            .deepPurple
                            .withOpacity(
                                0.25),

                        blurRadius: 30,

                        spreadRadius: 2,

                        offset:
                            const Offset(
                                0,
                                15),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      // =========================
                      // ICON
                      // =========================

                      Container(
                        padding:
                            const EdgeInsets
                                .all(22),

                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,

                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                  0xff7B2FF7),

                              Color(
                                  0xff4A00E0),
                            ],
                          ),

                          boxShadow: [

                            BoxShadow(
                              color: Colors
                                  .deepPurple
                                  .withOpacity(
                                      0.45),

                              blurRadius:
                                  25,

                              spreadRadius:
                                  3,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.lock_reset,

                          size: 60,

                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                          height: 25),

                      const Text(
                        "Reset Password 🔐",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color:
                              Colors.white,

                          fontSize: 30,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height: 10),

                      const Text(
                        "Create a strong new password for your account",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color:
                              Colors.white70,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                          height: 30),

                      // =========================
                      // PASSWORD
                      // =========================

                      TextField(
                        controller:
                            passwordController,

                        obscureText:
                            obscure1,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                        ),

                        decoration:
                            InputDecoration(
                          hintText:
                              "New Password",

                          prefixIcon:
                              const Icon(
                            Icons.lock,

                            color: Colors
                                .white70,
                          ),

                          suffixIcon:
                              IconButton(
                            icon: Icon(
                              obscure1
                                  ? Icons.visibility_off
                                  : Icons.visibility,

                              color: Colors
                                  .white70,
                            ),

                            onPressed:
                                () {

                              setState(() {
                                obscure1 =
                                    !obscure1;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 18),

                      // =========================
                      // CONFIRM PASSWORD
                      // =========================

                      TextField(
                        controller:
                            confirmController,

                        obscureText:
                            obscure2,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                        ),

                        decoration:
                            InputDecoration(
                          hintText:
                              "Confirm Password",

                          prefixIcon:
                              const Icon(
                            Icons
                                .lock_outline,

                            color: Colors
                                .white70,
                          ),

                          suffixIcon:
                              IconButton(
                            icon: Icon(
                              obscure2
                                  ? Icons.visibility_off
                                  : Icons.visibility,

                              color: Colors
                                  .white70,
                            ),

                            onPressed:
                                () {

                              setState(() {
                                obscure2 =
                                    !obscure2;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 30),

                      // =========================
                      // UPDATE BUTTON
                      // =========================

                      GestureDetector(
                        onTap: loading
                            ? null
                            : updatePassword,

                        child:
                            Container(
                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical:
                                18,
                          ),

                          decoration:
                              BoxDecoration(

                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                    0xff7B2FF7),

                                Color(
                                    0xffE940FF),
                              ],
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        22),

                            boxShadow: [

                              BoxShadow(
                                color: Colors
                                    .purple
                                    .withOpacity(
                                        0.45),

                                blurRadius:
                                    25,

                                spreadRadius:
                                    2,
                              ),
                            ],
                          ),

                          child: Center(
                            child: loading

                                ? const SizedBox(
                                    height: 24,
                                    width: 24,

                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors
                                              .white,

                                      strokeWidth:
                                          2.5,
                                    ),
                                  )

                                : const Text(
                                    "Update Password",

                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white,

                                      fontSize:
                                          18,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}