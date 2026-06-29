import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hire_hub/services/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController floatController;
  late AnimationController glowController;
  late AnimationController progressController;

  late Animation<double> floatAnim;
  late Animation<double> glowAnim;
  late Animation<double> progressAnim;

  @override
  void initState() {
    super.initState();

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    floatAnim = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
      ),
    );

    glowAnim = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );

    progressAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: progressController,
        curve: Curves.easeInOut,
      ),
    );

    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthGate(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    floatController.dispose();
    glowController.dispose();
    progressController.dispose();
    super.dispose();
  }

  Widget glowBlob({
    required double size,
    required Color color,
    required double top,
    required double left,
  }) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) {
        return Positioned(
          top: top,
          left: left,
          child: Transform.scale(
            scale: glowAnim.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(
                  alpha: 0.18,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(
                      alpha: 0.45,
                    ),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget animatedLogo() {
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, floatAnim.value),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget glassCard() {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.18,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.25,
            ),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          animatedLogo(),
          const SizedBox(height: 24),
          const Text(
            "Welcome Back",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "HIREHUB: Your AI-Powered College Placement Application ",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: progressAnim,
            builder: (_, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progressAnim.value,
                  minHeight: 10,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(
                    Colors.cyanAccent,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const Text(
            "Loading your personalized experience...",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff09090F),
                  Color(0xff1E1B4B),
                  Color(0xff312E81),
                  Color(0xff0F172A),
                ],
              ),
            ),
          ),
          glowBlob(
            size: 260,
            color: Colors.deepPurple,
            top: -50,
            left: -60,
          ),
          glowBlob(
            size: 220,
            color: Colors.cyan,
            top: 120,
            left: 280,
          ),
          glowBlob(
            size: 240,
            color: Colors.pinkAccent,
            top: 620,
            left: -40,
          ),
          Center(
            child: glassCard(),
          ),
        ],
      ),
    );
  }
}
