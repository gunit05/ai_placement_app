import 'dart:io';
import 'dart:ui';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

import 'premium_screen.dart';
import 'login_screen.dart';
import '../widgets/feedback_dialog.dart';
import 'terms_privacy_screen.dart';

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
  State<ProfileScreen> createState() => _ProfileScreenState();
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
    } catch (e) {
      showMsg("Image pick failed");
    }
  }

  Future<void> toggleFaceLock(bool value) async {
    try {
      if (!value) {
        widget.onToggleFace(false);
        showMsg("Face Lock disabled");
        return;
      }

      final available = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();

      if (!available || !supported) {
        showMsg("Biometric not available");
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to enable Face Lock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        widget.onToggleFace(true);
        showMsg("Face Lock enabled");
      }
    } catch (e) {
      showMsg("Biometric authentication failed");
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> showAbout() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff111C44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Text(
          "About App",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "AI Placement App 🚀\n\n"
          "Version: ${info.version} (${info.buildNumber})\n\n"
          "• Resume Analysis\n"
          "• AI Career Guidance\n"
          "• Interview Practice\n"
          "• Job Tracking\n"
          "• AI Chatbot\n"
          "• Coding Interview",
          style: const TextStyle(
            color: Colors.white70,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.22),
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

  Widget statCard(
    String value,
    String label,
    List<Color> colors,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
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
    Color textColor = Colors.white,
  }) {
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
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: glow(260, Colors.deepPurple.withOpacity(0.25)),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(300, Colors.purpleAccent.withOpacity(0.18)),
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
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(
                                0.20 + (glowController.value * 0.25),
                              ),
                              blurRadius: 35,
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
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.deepPurpleAccent,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 58,
                                    backgroundColor: Colors.deepPurple,
                                    backgroundImage: imagePath != null
                                        ? FileImage(File(imagePath!))
                                        : null,
                                    child: imagePath == null
                                        ? Text(
                                            widget.username[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.orange,
                                          Colors.pink,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
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
                              widget.username.split('@')[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.aiRole,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                statCard(
                                  "12",
                                  "Applied",
                                  [Colors.blue, Colors.cyan],
                                  Icons.work,
                                ),
                                statCard(
                                  "8",
                                  "Interviews",
                                  [Colors.purple, Colors.pink],
                                  Icons.mic,
                                ),
                                statCard(
                                  "85%",
                                  "Score",
                                  [Colors.green, Colors.teal],
                                  Icons.verified,
                                ),
                              ],
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
                            Icons.face,
                            "Face Lock",
                            [Colors.orange, Colors.deepOrange],
                            trailing: Switch(
                              value: widget.faceLock,
                              activeThumbColor: Colors.deepPurpleAccent,
                              onChanged: toggleFaceLock,
                            ),
                          ),
                          settingTile(
                            Icons.feedback,
                            "Send Feedback",
                            [Colors.pink, Colors.redAccent],
                            onTap: () => showFeedbackDialog(
                              context: context,
                              username: widget.username,
                              onSuccess: () {},
                            ),
                          ),
                          settingTile(
                            Icons.privacy_tip,
                            "Terms & Privacy",
                            [Colors.cyan, Colors.teal],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsPrivacyScreen(),
                                ),
                              );
                            },
                          ),
                          settingTile(
                            Icons.info_outline,
                            "About App",
                            [Colors.amber, Colors.orange],
                            onTap: showAbout,
                          ),
                          settingTile(
                            Icons.logout,
                            "Logout",
                            [Colors.red, Colors.redAccent],
                            textColor: Colors.red,
                            onTap: () async {
                              await Supabase.instance.client.auth.signOut();

                              if (!mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
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
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7B2FF7),
                          Color(0xff4A00E0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🚀 Premium AI Features",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Unlock premium interview AI, analytics & advanced career insights.",
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
                                builder: (_) => PremiumScreen(
                                  username: widget.username,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Upgrade Now",
                              style: TextStyle(
                                color: Color(0xff4A00E0),
                                fontWeight: FontWeight.bold,
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
