import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 4200,
      splashIconSize: double.infinity,
      backgroundColor: Colors.black,
      nextScreen: const LoginScreen(),
      pageTransitionType: PageTransitionType.fade,
      animationDuration: const Duration(milliseconds: 1400),
      splash: const PremiumSplashBody(),
    );
  }
}

class PremiumSplashBody extends StatefulWidget {
  const PremiumSplashBody({super.key});

  @override
  State<PremiumSplashBody> createState() =>
      _PremiumSplashBodyState();
}

class _PremiumSplashBodyState
    extends State<PremiumSplashBody>
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
              color: color.withOpacity(0.45),
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
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget animatedAIIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        pulseAnim,
        rotateAnim,
      ]),
      builder: (_, __) {
        return Transform.scale(
          scale: pulseAnim.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: rotateAnim.value,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.deepPurple.withOpacity(0.0),
                        Colors.deepPurple,
                        Colors.pinkAccent,
                        Colors.cyan,
                        Colors.deepPurple.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Transform.rotate(
                angle: -rotateAnim.value,
                child: Container(
                  width: 145,
                  height: 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 2,
                    ),
                  ),
                ),
              ),

              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.pinkAccent,
                      Colors.cyan,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.5),
                      blurRadius: 35,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
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
          floatingParticle(660, 170, 9),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                animatedAIIcon(),

                const SizedBox(height: 55),

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
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                AnimatedBuilder(
                  animation: floatAnim,
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(0, floatAnim.value),
                      child: const Text(
                        "AI Powered Career Growth Platform",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          letterSpacing: 0.9,
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
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.pinkAccent,
                        Colors.cyan,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.45),
                        blurRadius: 20,
                      ),
                    ],
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