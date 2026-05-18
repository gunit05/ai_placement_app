import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'premium_screen.dart' as premium;
import 'login_screen.dart';
import 'terms_privacy_screen.dart';
import '../widgets/feedback_dialog.dart';
import '../theme/premium_ui.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String aiRole;
  final bool faceLock;
  final ValueChanged<bool> onToggleFace;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.aiRole,
    required this.faceLock,
    required this.onToggleFace,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  String? imagePath;

  final ImagePicker picker = ImagePicker();
  final LocalAuthentication auth = LocalAuthentication();

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();
    loadImage();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  Future<void> loadImage() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      imagePath = prefs.getString('profile_image');
    });
  }

  Future<void> pickImage() async {
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', file.path);

      if (!mounted) return;

      setState(() {
        imagePath = file.path;
      });
    } catch (_) {
      showMsg("Image pick failed");
    }
  }

  Future<void> toggleFaceLock(bool value) async {
    try {
      if (!value) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('face_lock', false);

        widget.onToggleFace(false);
        showMsg("Biometric lock disabled");
        return;
      }

      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      final available =
          await auth.getAvailableBiometrics();

      if (!supported ||
          !canCheck ||
          available.isEmpty) {
        showMsg("Biometric not available");
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Verify identity',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('face_lock', true);

        widget.onToggleFace(true);
        showMsg("Biometric lock enabled");
      } else {
        widget.onToggleFace(false);
      }
    } catch (_) {
      showMsg("Biometric authentication failed");
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> showAbout() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        final isDark =
            Theme.of(context).brightness ==
                Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark
              ? AppTheme.darkCard
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "About App",
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          content: Text(
            "AI Placement App\n\n"
            "Version: ${info.version} (${info.buildNumber})\n\n"
            "AI-powered interview preparation, resume analysis, career coaching, and placement assistance.",
            style: TextStyle(
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
              height: 1.5,
            ),
          ),
        );
      },
    );
  }

  Widget glassCard({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget settingTile(
    IconData icon,
    String title,
    List<Color> colors, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ??
              (isDark
                  ? Colors.white
                  : Colors.black87),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            color: isDark
                ? Colors.white54
                : Colors.black45,
            size: 16,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: glow(
              260,
              AppTheme.primary.withOpacity(0.22),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(
              300,
              Colors.blue.withOpacity(0.10),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: glowController,
                    builder: (_, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary
                                  .withOpacity(
                                0.15 +
                                    (glowController.value *
                                        0.15),
                              ),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Stack(
                              alignment:
                                  Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 58,
                                  backgroundColor:
                                      AppTheme.primary,
                                  backgroundImage:
                                      imagePath != null
                                          ? FileImage(
                                              File(
                                                imagePath!,
                                              ),
                                            )
                                          : null,
                                  child: imagePath == null
                                      ? Text(
                                          widget.username[0]
                                              .toUpperCase(),
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                            fontSize: 40,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                GestureDetector(
                                  onTap: pickImage,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(
                                            10),
                                    decoration:
                                        BoxDecoration(
                                      gradient:
                                          AppTheme.aiGradient,
                                      borderRadius:
                                          BorderRadius
                                              .circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Text(
                              widget.username
                                  .split('@')[0],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary
                                    .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                              child: Text(
                                widget.aiRole,
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
                    ),
                  ),

                  const SizedBox(height: 24),

                  glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          settingTile(
                            Icons.fingerprint,
                            "Biometric Lock",
                            [
                              Colors.orange,
                              Colors.deepOrange
                            ],
                            trailing: Switch(
                              value: widget.faceLock,
                              activeColor:
                                  AppTheme.primary,
                              onChanged:
                                  toggleFaceLock,
                            ),
                          ),

                          settingTile(
                            Icons.feedback,
                            "Send Feedback",
                            [
                              Colors.pink,
                              Colors.redAccent
                            ],
                            onTap: () =>
                                showFeedbackDialog(
                              context: context,
                              username:
                                  widget.username,
                              onSuccess: () {},
                            ),
                          ),

                          settingTile(
                            Icons.privacy_tip,
                            "Terms & Privacy",
                            [
                              Colors.cyan,
                              Colors.teal
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TermsPrivacyScreen(),
                                ),
                              );
                            },
                          ),

                          settingTile(
                            Icons.info_outline,
                            "About App",
                            [
                              Colors.amber,
                              Colors.orange
                            ],
                            onTap: showAbout,
                          ),

                          settingTile(
                            Icons.logout,
                            "Logout",
                            [
                              Colors.red,
                              Colors.redAccent
                            ],
                            textColor: Colors.red,
                            onTap: () async {
                              await Supabase.instance.client
                                  .auth
                                  .signOut();

                              if (!mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient:
                          AppTheme.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Premium AI Features",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Unlock advanced AI interviews, analytics & career intelligence.",
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                               builder: (_) => premium.PremiumScreen(
                                  username:
                                      widget.username,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(20),
                            ),
                            child: const Text(
                              "Upgrade Now",
                              style: TextStyle(
                                color:
                                    Color(0xff4A00E0),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget glow(double size, Color color) {
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