import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hire_hub/theme/premium_ui.dart';
import 'package:hire_hub/theme/theme_controller.dart'; 
import 'package:hire_hub/screens/auth/login_screen.dart';
import 'package:hire_hub/screens/admin/admin_resume_list_screen.dart';
import 'package:hire_hub/screens/admin/admin_add_job_screen.dart';
import 'package:hire_hub/screens/admin/admin_applications_screen.dart';
import 'package:hire_hub/screens/admin/admin_interview_list_screen.dart';
import 'package:hire_hub/screens/admin/admin_coding_list_screen.dart';
import 'package:hire_hub/screens/candidate/shortlist_dashboard.dart';
import 'package:hire_hub/screens/admin/admin_feedback_screen.dart';
import 'package:hire_hub/screens/admin/admin_logs_analytics.dart';

class AdminDashboard extends StatelessWidget {
  final String username;
  const AdminDashboard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Admin Panel",
                            style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold)),
                        Text(username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: secondaryColor, fontSize: 14)),
                      ],
                    ),
                  ),
                  // 🔑 Theme Toggle Button (upper right corner)
                  IconButton(
                    icon: Icon(
                      themeController.isDark ? Icons.light_mode : Icons.dark_mode,
                      color: textColor,
                    ),
                    onPressed: () => themeController.toggleTheme(),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12)),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.dashboard_customize, color: Colors.white, size: 80),
                    const SizedBox(height: 16),
                    Text("HIREHUB Admin",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Manage jobs, resumes, interviews & analytics",
                        textAlign: TextAlign.center, style: TextStyle(color: secondaryColor, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text("Admin Controls",
                  style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // GRID
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _tile(context, "Resumes", Icons.picture_as_pdf, Colors.blue, const AdminResumeListScreen()),
                  _tile(context, "Applications", Icons.assignment, Colors.orange, const AdminApplicationsScreen()),
                  _tile(context, "Interviews", Icons.mic, Colors.purple, const AdminInterviewListScreen()),
                  _tile(context, "Coding", Icons.code, Colors.green, const AdminCodingListScreen()),
                  _tile(context, "Jobs", Icons.work, Colors.cyan, const AdminAddJobScreen()),
                  _tile(context, "Shortlist", Icons.star, Colors.amber, const ShortlistDashboard()),
                  _tile(context, "Feedback", Icons.feedback, Colors.pink, const AdminFeedbackScreen()),
                  _tile(context, "Analytics", Icons.bar_chart, Colors.teal, const AdminLogsAnalytics()),
                  _tile(context, "Logout", Icons.logout, Colors.red, const LoginScreen(), logout: true),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String title, IconData icon, Color color, Widget page, {bool logout = false}) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    return GestureDetector(
      onTap: () async {
        if (logout) {
          await Supabase.instance.client.auth.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(backgroundColor: color, child: Icon(icon, size: 28, color: Colors.white)),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
