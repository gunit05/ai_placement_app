import 'package:flutter/material.dart';
import '../theme/premium_ui.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  Widget sectionCard({
    required IconData icon,
    required String title,
    required String content,
    required List<Color> colors,
  }) {
    return PremiumCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.20),
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      title,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "Terms & Privacy",
      subtitle:
          "Policies, legal terms & support information",
      icon: Icons.privacy_tip,
      scrollable: true,
      child: Column(
        children: [
          sectionCard(
            icon: Icons.gavel,
            title: "Terms & Conditions",
            colors: const [
              Color(0xff7B2FF7),
              Color(0xffE940FF),
            ],
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
            colors: const [
              Color(0xff00C9FF),
              Color(0xff92FE9D),
            ],
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
            colors: const [
              Color(0xffFC466B),
              Color(0xff3F5EFB),
            ],
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
            colors: const [
              Color(0xffFF6A00),
              Color(0xffEE0979),
            ],
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
    );
  }
}