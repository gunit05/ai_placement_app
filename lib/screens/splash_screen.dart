import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_gate.dart';
import '../theme/premium_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController glowController;
  late AnimationController floatController;

  late Animation<double> glowAnim;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    glowAnim = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );

    floatAnim = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(
      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
      ),
    );

    glowController.repeat(reverse: true);
    floatController.repeat(reverse: true);

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
    glowController.dispose();
    floatController.dispose();
    super.dispose();
  }

  Widget glowCircle({
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
                color: color.withOpacity(0.18),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
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
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.35),
                  blurRadius: 60,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Image.asset(
              'assets/splash.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff050816),
                  Color(0xff101A56),
                  Color(0xff1A063F),
                  Color(0xff040B2D),
                ],
              ),
            ),
          ),
          glowCircle(
            size: 260,
            color: Colors.deepPurple,
            top: -50,
            left: -60,
          ),
          glowCircle(
            size: 220,
            color: Colors.cyan,
            top: 180,
            left: 280,
          ),
          glowCircle(
            size: 240,
            color: Colors.pinkAccent,
            top: 620,
            left: -40,
          ),
          Center(
            child: animatedLogo(),
          ),
        ],
      ),
    );
  }
}
