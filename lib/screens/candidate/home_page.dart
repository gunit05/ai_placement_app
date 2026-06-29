import 'package:flutter/material.dart';
import 'package:hire_hub/screens/candidate/notifications_screen.dart';
import 'package:hire_hub/screens/ai_prep/resume_upload_screen.dart';
import 'package:hire_hub/screens/ai_prep/chatbot_screen.dart';
import 'package:hire_hub/screens/ai_prep/interview_screen.dart';
import 'package:hire_hub/screens/ai_prep/ai_skill_onboarding_screen.dart';
import 'package:hire_hub/screens/ai_prep/quiz_screen.dart';
import 'package:hire_hub/screens/ai_prep/aptitude_screen.dart';
import 'package:hire_hub/theme/premium_ui.dart';

class HomePage extends StatelessWidget {
  final String username;
  final List<String> skills;
  final String recommendedRole;
  final String salaryRange;
  final List<String> aiSuggestions;

  const HomePage({
    super.key,
    required this.username,
    this.skills = const [],
    this.recommendedRole = "",
    this.salaryRange = "",
    this.aiSuggestions = const [],
  });

  void go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = username.split('@')[0];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
              top: -120,
              left: -80,
              child: _glow(260, AppTheme.primary.withOpacity(0.22))),
          Positioned(
              bottom: -140,
              right: -100,
              child: _glow(300, Colors.blue.withOpacity(0.10))),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $user 👋",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Welcome back to HIREHUB",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// EDIT AI PROFILE ICON
                      GestureDetector(
                        onTap: () => go(context,
                            AiSkillOnboardingScreen(username: username)),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit,
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 12),

                      /// NOTIFICATIONS ICON
                      GestureDetector(
                        onTap: () => go(
                            context, NotificationsScreen(username: username)),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_rounded,
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// HERO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your AI-Powered Career Companion",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          skills.isEmpty
                              ? "Smart interview prep, resume analysis & career growth."
                              : "Top skills: ${skills.take(3).join(", ")}",
                          style: const TextStyle(
                              color: Colors.white70, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        PremiumButton(
                          text: "Start Interview Prep",
                          icon: Icons.arrow_forward,
                          onTap: () =>
                              go(context, InterviewScreen(username: username)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// QUICK ACTIONS
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      _quickCard(
                          context,
                          isDark,
                          Icons.upload_file,
                          "Upload Resume",
                          ResumeUploadScreen(username: username)),
                      _quickCard(context, isDark, Icons.smart_toy, "AI Chatbot",
                          const ChatbotScreen()),
                      _quickCard(context, isDark, Icons.quiz, "Quizzes",
                          QuizScreen(username: username)),
                      _quickCard(context, isDark, Icons.school,
                          "Aptitude Tests", AptitudeScreen(username: username)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// CAREER INSIGHTS SECTION

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Career Insights",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recommended Role",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              recommendedRole.isNotEmpty
                                  ? recommendedRole
                                  : "AI Engineer",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Expected Salary: ${salaryRange.isNotEmpty ? salaryRange : "₹6 LPA - ₹15 LPA"}",
                              style: TextStyle(
                                color:
                                    isDark ? Colors.amber : Colors.deepOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "AI Suggestions",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...(aiSuggestions.isEmpty
                                    ? [
                                        "Improve Resume ATS Score",
                                        "Practice Aptitude Daily",
                                        "Build Real Flutter Projects",
                                        "Prepare Mock Interviews",
                                      ]
                                    : aiSuggestions)
                                .map(
                              (s) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        s,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(BuildContext context, bool isDark, IconData icon,
      String title, Widget page) {
    return GestureDetector(
      onTap: () => go(context, page),
      child: PremiumCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.aiGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
