import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7B2FF7);
  static const Color secondary = Color(0xFF4A00E0);
  static const Color accent = Color(0xFF9D4DFF);

  static const Color darkBg = Color(0xFF040B2D);
  static const Color darkCard = Color(0xFF111C44);
  static const Color darkCard2 = Color(0xFF09122F);

  static const Color lightBg = Color(0xFFF7F8FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8EAF6);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9D4DFF),
      Color(0xFF7B2FF7),
      Color(0xFF4A00E0),
    ],
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
    ],
  );
}

class AppThemes {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppTheme.darkBg,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.dark(
      primary: AppTheme.primary,
      secondary: AppTheme.secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    cardColor: AppTheme.darkCard,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppTheme.lightBg,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.light(
      primary: AppTheme.primary,
      secondary: AppTheme.secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    cardColor: AppTheme.lightCard,
  );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              320,
              Colors.blue.withOpacity(0.10),
            ),
          ),
          Positioned(
            top: 150,
            right: -50,
            child: _glow(
              180,
              Colors.purpleAccent.withOpacity(0.12),
            ),
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
                        const SizedBox(height: 24),
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
                        const SizedBox(height: 24),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
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
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkCard,
                  AppTheme.darkCard2,
                ],
              )
            : const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFF7F8FC),
                ],
              ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
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

  const PremiumButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
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
              if (icon != null) Icon(icon, color: Colors.white),
              if (icon != null) const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
