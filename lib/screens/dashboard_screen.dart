import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'ai_skill_onboarding_screen.dart';
import 'resume_upload_screen.dart';
import 'resume_score_screen.dart';
import 'jobs_screen.dart';
import 'application_history_screen.dart';
import 'chatbot_screen.dart';
import 'interview_screen.dart';
import 'coding_interview_screen.dart';
import 'ai_career_guidance_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'home_page.dart';

import '../theme/premium_ui.dart';
import '../theme/theme_controller.dart';

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({
    super.key,
    required this.username,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  int index = 0;
  String aiRole = "AI Engineer";
  List<String> skills = [];
  bool faceLock = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await checkOnboarding();
    await loadPrefs();
    await loadAiData();

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    final seen = prefs.getBool('seen_onboarding') ?? false;

    if (!seen && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiSkillOnboardingScreen(
            username: widget.username,
          ),
        ),
      );
    }
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      faceLock = prefs.getBool('face_lock') ?? false;
    });
  }

  Future<bool> authenticateUser() async {
    try {
      final canCheck = await auth.canCheckBiometrics;

      if (!canCheck) return false;

      return await auth.authenticate(
        localizedReason: "Authenticate with Face ID / Fingerprint",
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleFace(bool v) async {
    if (v) {
      final ok = await authenticateUser();
      if (!ok) return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('face_lock', v);

    if (!mounted) return;

    setState(() => faceLock = v);
  }

  Future<void> loadAiData() async {
    try {
      final res = await Supabase.instance.client
          .from('user_skills')
          .select(
            'recommended_role, skills',
          )
          .eq('username', widget.username)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        aiRole = res?['recommended_role'] ?? "AI Engineer";

        skills = List<String>.from(
          res?['skills'] ?? [],
        );
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    final pages = [
      HomePage(
        username: widget.username,
        skills: skills,
      ),
      _explorePage(),
      ProfileScreen(
        username: widget.username,
        aiRole: aiRole,
        faceLock: faceLock,
        onToggleFace: toggleFace,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: pages,
          ),
          Positioned(
            top: 55,
            right: 20,
            child: SafeArea(
              child: _topThemeButton(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _premiumBottomNav(isDark),
    );
  }

  Widget _premiumBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xff111C44),
                  Color(0xff09122F),
                ],
              )
            : const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xffF7F8FC),
                ],
              ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _navItem(
            Icons.home_rounded,
            "Home",
            0,
          ),
          _navItem(
            Icons.grid_view_rounded,
            "Explore",
            1,
          ),
          _navItem(
            Icons.person_rounded,
            "Profile",
            2,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int itemIndex,
  ) {
    final selected = index == itemIndex;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => index = itemIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            gradient: selected ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topThemeButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        themeController.toggleTheme();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppTheme.aiGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 18,
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _explorePage() {
    final items = [
      {
        "title": "Resume",
        "icon": Icons.upload_file,
        "page": ResumeUploadScreen(
          username: widget.username,
        ),
      },
      {
        "title": "Score",
        "icon": Icons.verified,
        "page": ResumeScoreScreen(
          username: widget.username,
        ),
      },
      {
        "title": "Jobs",
        "icon": Icons.work,
        "page": JobsScreen(
          username: widget.username,
        ),
      },
      {
        "title": "History",
        "icon": Icons.history,
        "page": ApplicationHistoryScreen(
          username: widget.username,
        ),
      },
      {
        "title": "Chatbot",
        "icon": Icons.smart_toy,
        "page": const ChatbotScreen(),
      },
      {
        "title": "Interview",
        "icon": Icons.mic,
        "page": InterviewScreen(
          username: widget.username,
        ),
      },
      {
        "title": "Coding",
        "icon": Icons.code,
        "page": CodingInterviewScreen(
          username: widget.username,
        ),
      },
      {
        "title": "Career AI",
        "icon": Icons.psychology,
        "page": AICareerGuidanceScreen(
          username: widget.username,
        ),
      },
      {
        "title": "Alerts",
        "icon": Icons.notifications,
        "page": NotificationsScreen(
          username: widget.username,
        ),
      },
    ];

    return PremiumScreen(
      title: "Explore",
      subtitle: "AI placement toolkit",
      icon: Icons.dashboard_customize,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (_, i) {
          final item = items[i];

          return GestureDetector(
            onTap: () => _go(item['page'] as Widget),
            child: PremiumCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _go(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }
}
