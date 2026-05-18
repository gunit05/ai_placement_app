import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/auth_gate.dart';
import '../theme/premium_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseController;
  late AnimationController rotateController;
  late AnimationController floatController;
  late AnimationController textController;

  late Animation<double> pulseAnim;
  late Animation<double> rotateAnim;
  late Animation<double> floatAnim;
  late Animation<double> textAnim;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    pulseAnim = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: Curves.easeInOut,
      ),
    );

    rotateAnim = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(rotateController);

    floatAnim = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
      ),
    );

    textAnim = CurvedAnimation(
      parent: textController,
      curve: Curves.elasticOut,
    );

    pulseController.repeat(reverse: true);
    rotateController.repeat();
    floatController.repeat(reverse: true);
    textController.forward();

    Timer(
      const Duration(seconds: 4),
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
    pulseController.dispose();
    rotateController.dispose();
    floatController.dispose();
    textController.dispose();
    super.dispose();
  }

  Widget glowOrb({
    required double size,
    required Color color,
    required double top,
    required double left,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 90,
              spreadRadius: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget floatingParticle(
    double top,
    double left,
    double size,
  ) {
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, __) {
        return Positioned(
          top: top + floatAnim.value,
          left: left,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget animatedRobot() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        pulseAnim,
        rotateAnim,
        floatAnim,
      ]),
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, floatAnim.value),
          child: Transform.scale(
            scale: pulseAnim.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: rotateAnim.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
                          Colors.cyanAccent,
                          Colors.deepPurpleAccent,
                          Colors.pinkAccent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.cyan.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Image.asset(
                    'assets/icon/ai_robot.png',
                  ),
                ),
              ],
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
                  Color(0xff020817),
                  Color(0xff101A56),
                  Color(0xff25074F),
                  Color(0xff040B2D),
                ],
              ),
            ),
          ),

          glowOrb(
            size: 260,
            color: Colors.deepPurple,
            top: -60,
            left: -70,
          ),

          glowOrb(
            size: 180,
            color: Colors.pinkAccent,
            top: 140,
            left: 290,
          ),

          glowOrb(
            size: 220,
            color: Colors.cyan,
            top: 600,
            left: -40,
          ),

          floatingParticle(100, 50, 14),
          floatingParticle(220, 310, 10),
          floatingParticle(420, 90, 12),
          floatingParticle(540, 280, 16),

          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                animatedRobot(),

                const SizedBox(height: 50),

                AnimatedBuilder(
                  animation: textAnim,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: textAnim.value,
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.purpleAccent,
                            Colors.cyanAccent,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "AI Placement App",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                AnimatedBuilder(
                  animation: floatAnim,
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        floatAnim.value,
                      ),
                      child: const Text(
                        "AI Powered Career Growth Platform",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                Container(
                  width: 170,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20),
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}