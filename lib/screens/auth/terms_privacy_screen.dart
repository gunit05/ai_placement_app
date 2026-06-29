import 'package:flutter/material.dart';
import 'package:hire_hub/theme/premium_ui.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  Widget sectionCard({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
    required List<Color> iconColors,
  }) {
    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(top: -120, left: -80, child: glow(260, AppTheme.primary.withOpacity(0.22))),
          Positioned(bottom: -140, right: -100, child: glow(300, AppTheme.accent.withOpacity(0.10))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const Spacer(),
                      Text("Terms & Privacy",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          )),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  sectionCard(
                    icon: Icons.gavel,
                    title: "Terms & Conditions",
                    isDark: isDark,
                    iconColors: const [Color(0xff7B2FF7), Color(0xffE940FF)],
                    content:
                     "• This application is designed for educational, placement preparation, AI career guidance, and job assistance purposes only.\n\n"
                        "• Users are fully responsible for information they provide including resumes, interview responses, profile details, and uploaded content.\n\n"
                        "• Any misuse, fraudulent activity, abusive behavior, spam, fake applications, or policy violations may lead to account suspension or permanent access restriction.\n\n"
                        "• Job recommendations and AI suggestions are generated for assistance only and do not guarantee employment outcomes.\n\n"
                        "• Interview scores, resume analysis, ATS scoring, and AI feedback are estimated guidance tools and should not be treated as official recruiter decisions.\n\n"
                        "• We reserve the right to improve, modify, suspend, or discontinue features without prior notice.",
                  ),

                  const SizedBox(height: 18),

                  sectionCard(
                    icon: Icons.privacy_tip,
                    title: "Privacy Policy",
                    isDark: isDark,
                    iconColors: const [Color(0xff00C9FF), Color(0xff92FE9D)],
                    content:
                       "• We collect only the minimum necessary data required for account functionality, personalization, job recommendations, and feature access.\n\n"
                        "• User profile details, resumes, skills, analytics, interview data, and chatbot interactions may be stored securely for app functionality.\n\n"
                        "• Your personal data is never sold, rented, or shared with unauthorized third parties.\n\n"
                        "• Cloud storage, database, and authentication systems are protected using secure backend services like Supabase.\n\n"
                        "• Analytics may be used to improve user experience, recommendation accuracy, feature quality, and performance monitoring.\n\n"
                        "• Users can request profile deletion, account removal, or stored data removal where applicable.",
                  ),

                  const SizedBox(height: 18),

                  sectionCard(
                    icon: Icons.security,
                    title: "Security & User Safety",
                    isDark: isDark,
                    iconColors: const [Color(0xffFC466B), Color(0xff3F5EFB)],
                    content:
                     "• We use secure authentication methods to protect account access.\n\n"
                        "• Users should keep login credentials private and avoid sharing sensitive information.\n\n"
                        "• Password reset and account recovery should only be performed by the account owner.\n\n"
                        "• While we implement protection measures, no digital platform can guarantee 100% absolute security.\n\n"
                        "• Suspicious activity may be monitored for fraud prevention and platform safety.",
                  

                  ),

                  const SizedBox(height: 18),

                  sectionCard(
                    icon: Icons.contact_mail,
                    title: "Support & Contact",
                    isDark: isDark,
                    iconColors: const [Color(0xffFF6A00), Color(0xffEE0979)],
                    content:
                    "Need help with the application?\n\n"
                        "📧 gunitraj90@gmail.com\n\n"
                        "Support is available for:\n"
                        "• Login/account issues\n"
                        "• Resume upload problems\n"
                        "• Interview feature issues\n"
                        "• Job application bugs\n"
                        "• Payment/support queries\n"
                        "• Feedback and suggestions\n\n"
                        "We aim to respond as quickly as possible.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
