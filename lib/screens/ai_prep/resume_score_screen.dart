import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:hire_hub/theme/premium_ui.dart';

class ResumeScoreScreen extends StatefulWidget {
  final String username;

  const ResumeScoreScreen({
    super.key,
    required this.username,
  });

  @override
  State<ResumeScoreScreen> createState() =>
      _ResumeScoreScreenState();
}

class _ResumeScoreScreenState
    extends State<ResumeScoreScreen> {
  bool loading = true;

  int manualScore = 0;
  int aiScore = 0;
  bool adminOverride = false;

  String missing = "";
  String suggestions = "";
  String strengths = "";
  String remarks = "";

  @override
  void initState() {
    super.initState();
    fetchScore();
  }

  Future<void> fetchScore() async {
    try {
      final data = await Supabase.instance.client
          .from('resume_scores')
          .select()
          .eq('username', widget.username)
          .maybeSingle();

      if (data != null) {
        adminOverride =
            data['admin_override'] ?? false;

        manualScore =
            data['score'] ?? 0;

        aiScore =
            data['ai_score'] ?? 0;

        missing =
            data['missing_skills'] ?? "";

        suggestions =
            data['ai_suggestions'] ?? "";

        strengths =
            data['strengths'] ?? "";

        remarks =
            data['remarks'] ?? "";
      }
    } catch (_) {}

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Hybrid ATS Report"),
            pw.Text("Manual Score: $manualScore%"),
            pw.Text("AI Score: $aiScore%"),
            pw.Text("Missing Skills: $missing"),
            pw.Text("AI Strengths: $strengths"),
            pw.Text("AI Suggestions: $suggestions"),
            pw.Text("Admin Remarks: $remarks"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  Widget scoreCard(
    BuildContext context,
    String title,
    int score,
    Color color,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return PremiumCard(
      child: Column(
        children: [
          Text(
            "$score%",
            style: TextStyle(
              color: color,
              fontSize: 44,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(
    BuildContext context,
    String title,
    String text,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return PremiumCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black87,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text.isEmpty ? "-" : text,
            style: TextStyle(
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "ATS Results",
      subtitle:
          "Manual + AI Resume Analysis",
      icon: Icons.analytics,
      child: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: scoreCard(
                          context,
                          adminOverride
                              ? "Admin Final Score"
                              : "Manual ATS",
                          manualScore,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: scoreCard(
                          context,
                          "Groq AI ATS",
                          aiScore,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  infoCard(
                    context,
                    "Missing Skills",
                    missing,
                  ),

                  const SizedBox(height: 16),

                  infoCard(
                    context,
                    "AI Strengths",
                    strengths,
                  ),

                  const SizedBox(height: 16),

                  infoCard(
                    context,
                    "AI Suggestions",
                    suggestions,
                  ),

                  const SizedBox(height: 16),

                  infoCard(
                    context,
                    "Admin Remarks",
                    remarks,
                  ),

                  const SizedBox(height: 24),

                  PremiumButton(
                    text:
                        "Download PDF Report",
                    icon: Icons.picture_as_pdf,
                    onTap: generatePDF,
                  ),
                ],
              ),
            ),
    );
  }
}