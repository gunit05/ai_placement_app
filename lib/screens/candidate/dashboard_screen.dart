import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'package:hire_hub/screens/candidate/notifications_screen.dart';
import 'package:hire_hub/screens/ai_prep/ai_skill_onboarding_screen.dart';
import 'package:hire_hub/screens/ai_prep/resume_upload_screen.dart';
import 'package:hire_hub/screens/ai_prep/resume_score_screen.dart';
import 'package:hire_hub/screens/candidate/jobs_screen.dart';
import 'package:hire_hub/screens/candidate/application_history_screen.dart';
import 'package:hire_hub/screens/ai_prep/chatbot_screen.dart';
import 'package:hire_hub/screens/ai_prep/aptitude_screen.dart';
import 'package:hire_hub/screens/ai_prep/quiz_screen.dart';
import 'package:hire_hub/screens/ai_prep/interview_screen.dart';
import 'package:hire_hub/screens/ai_prep/coding_interview_screen.dart';
import 'package:hire_hub/screens/ai_prep/ai_career_guidance_screen.dart';
import 'package:hire_hub/screens/candidate/profile_screen.dart';
import 'package:hire_hub/screens/candidate/home_page.dart';
import 'package:hire_hub/screens/ai_prep/youtube_ai_videos_screen.dart';

import 'package:hire_hub/theme/premium_ui.dart';

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
          .select('recommended_role, skills')
          .eq('username', widget.username)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        aiRole = res?['recommended_role'] ?? "AI Engineer";
        skills = List<String>.from(res?['skills'] ?? []);
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
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: _premiumBottomNav(isDark),
    );
  }

  Widget _premiumBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
          _navItem(Icons.home_rounded, "Home", 0),
          _navItem(Icons.grid_view_rounded, "Explore", 1),
          _navItem(Icons.person_rounded, "Profile", 2),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _explorePage() {
    final items = [
      {
        "title": "Upload Resume",
        "subtitle": "Get AI feedback on your resume",
        "icon": Icons.upload_file,
        "page": ResumeUploadScreen(username: widget.username),
      },
      {
        "title": "AI Resume Analyzer",
        "subtitle": "ATS + AI Resume Review",
        "icon": Icons.description_rounded,
        "page": ResumeScoreScreen(username: widget.username),
      },
      {
        "title": "Jobs",
        "subtitle": "Find your next opportunity",
        "icon": Icons.work,
        "page": JobsScreen(username: widget.username),
      },
      {
        "title": "Application History",
        "subtitle": "View your application history",
        "icon": Icons.history,
        "page": ApplicationHistoryScreen(username: widget.username),
      },
      {
        "title": "Aptitude Tests",
        "subtitle": "Sharpen your skills",
        "icon": Icons.school,
        "page": AptitudeScreen(username: widget.username),
      },
      {
        "title": "Quizzes",
        "subtitle": "Test your knowledge",
        "icon": Icons.quiz,
        "page": QuizScreen(username: widget.username),
      },
      {
        "title": "AI Chatbot",
        "subtitle": "Career guidance assistant",
        "icon": Icons.smart_toy,
        "page": const ChatbotScreen(),
      },
      {
        "title": "Career Mentor",
        "subtitle": "Personalized AI Guidance",
        "icon": Icons.psychology,
        "page": AICareerGuidanceScreen(username: widget.username),
      },
      {
        "title": "Notifications",
        "subtitle": "Stay updated with latest alerts",
        "icon": Icons.notifications,
        "page": NotificationsScreen(username: widget.username),
      },
      {
        "title": "AI Videos",
        "subtitle": "Curated learning content",
        "icon": Icons.video_library,
        "page": YoutubeAiVideosScreen(username: widget.username),
      },
      {
        "title": "Mock Interview",
        "subtitle": "Real AI Interview Simulation",
        "icon": Icons.mic,
        "page": InterviewScreen(username: widget.username),
      },
      {
        "title": "Coding Arena",
        "subtitle": "Practice & Get Evaluated",
        "icon": Icons.code,
        "page": CodingInterviewScreen(username: widget.username),
      },
    ];

    return PremiumScreen(
      title: "Explore",
      subtitle: "Discover AI-Powered Tools",
      icon: Icons.dashboard_customize,
      scrollable: false,
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.90,
        ),
        itemBuilder: (_, i) {
          final item = items[i];

          return GestureDetector(
            onTap: () => _go(item['page'] as Widget),
            child: PremiumCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['subtitle'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey.shade700,
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
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
