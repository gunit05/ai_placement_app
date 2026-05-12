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
  bool darkMode = true;
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
      darkMode = prefs.getBool('dark_mode') ?? true;
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

  Future<void> toggleDark(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', v);

    if (!mounted) return;

    setState(() => darkMode = v);
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
    if (loading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: IndexedStack(
        index: index,
        children: [
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff070E38),
        currentIndex: index,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => index = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _explorePage() {
    final items = [
      {
        "title": "Resume",
        "subtitle": "Upload & analyze",
        "icon": Icons.upload_file,
        "page": ResumeUploadScreen(username: widget.username),
      },
      {
        "title": "Score",
        "subtitle": "ATS Resume Score",
        "icon": Icons.verified,
        "page": ResumeScoreScreen(username: widget.username),
      },
      {
        "title": "Jobs",
        "subtitle": "Find opportunities",
        "icon": Icons.work,
        "page": JobsScreen(username: widget.username),
      },
      {
        "title": "History",
        "subtitle": "Track applications",
        "icon": Icons.history,
        "page": ApplicationHistoryScreen(username: widget.username),
      },
      {
        "title": "Chatbot",
        "subtitle": "AI Assistant",
        "icon": Icons.smart_toy,
        "page": const ChatbotScreen(),
      },
      {
        "title": "Interview",
        "subtitle": "Mock Practice",
        "icon": Icons.mic,
        "page": InterviewScreen(username: widget.username),
      },
      {
        "title": "Coding",
        "subtitle": "Coding Round",
        "icon": Icons.code,
        "page": CodingInterviewScreen(username: widget.username),
      },
      {
        "title": "Career AI",
        "subtitle": "Roadmap & guidance",
        "icon": Icons.psychology,
        "page": AICareerGuidanceScreen(username: widget.username),
      },
      {
        "title": "Notifications",
        "subtitle": "Latest alerts",
        "icon": Icons.notifications,
        "page": NotificationsScreen(username: widget.username),
      },
    ];

    return PremiumScreen(
      title: "Explore",
      subtitle: "All AI placement tools",
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

          return PremiumTile(
            title: item['title'] as String,
            icon: item['icon'] as IconData,
            color: AppTheme.primary,
            onTap: () => _go(item['page'] as Widget),
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
