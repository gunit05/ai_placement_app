import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7B2FF7);
  static const Color secondary = Color(0xFF4A00E0);
  static const Color darkBg = Color(0xFF040B2D);
  static const Color card1 = Color(0xFF111C44);
  static const Color card2 = Color(0xFF09122F);
}

class PremiumScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;

  const PremiumScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.actions,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _glow(260, Colors.deepPurple.withOpacity(0.25)),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(300, Colors.purpleAccent.withOpacity(0.18)),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: _glow(180, Colors.blue.withOpacity(0.08)),
          ),
          SafeArea(
            child: scrollable
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        PremiumHeader(
                          title: title,
                          subtitle: subtitle,
                          icon: icon,
                          actions: actions,
                        ),
                        const SizedBox(height: 25),
                        child,
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        PremiumHeader(
                          title: title,
                          subtitle: subtitle,
                          icon: icon,
                          actions: actions,
                        ),
                        const SizedBox(height: 25),
                        Expanded(child: child),
                      ],
                    ),
                  ),
          ),
        ],
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

class PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? actions;

  const PremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIcon(icon: icon),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

class GlassIcon extends StatelessWidget {
  final IconData icon;

  const GlassIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xffFF6B6B),
                Color(0xffFF8E53),
                Color(0xff7B2FF7),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.card1,
            AppTheme.card2,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xffFF6B6B),
              Color(0xff7B2FF7),
              Color(0xff4A00E0),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white),

              if (icon != null)
                const SizedBox(width: 10),

              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const PremiumTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  List<Color> _iconGradient(IconData icon) {
    if (icon == Icons.work) {
      return [Colors.orange, Colors.deepOrange];
    }
    if (icon == Icons.upload_file) {
      return [Colors.blue, Colors.cyan];
    }
    if (icon == Icons.verified) {
      return [Colors.green, Colors.teal];
    }
    if (icon == Icons.smart_toy) {
      return [Colors.purple, Colors.pink];
    }
    if (icon == Icons.mic) {
      return [Colors.red, Colors.pinkAccent];
    }
    if (icon == Icons.code) {
      return [Colors.indigo, Colors.blue];
    }
    if (icon == Icons.psychology) {
      return [Colors.cyan, Colors.teal];
    }
    if (icon == Icons.notifications) {
      return [Colors.amber, Colors.orange];
    }

    return [AppTheme.primary, AppTheme.secondary];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _iconGradient(icon);

    return GestureDetector(
      onTap: onTap,
      child: PremiumCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}