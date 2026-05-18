import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../theme/premium_ui.dart';

class ResumeScoreScreen extends StatefulWidget {
  final String username;

  const ResumeScoreScreen({
    super.key,
    required this.username,
  });

  @override
  State<ResumeScoreScreen> createState() => _ResumeScoreScreenState();
}

class _ResumeScoreScreenState extends State<ResumeScoreScreen> {
  bool loading = true;

  int score = 0;
  String missing = "";
  String suggestions = "";

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

      if (!mounted) return;

      if (data != null) {
        setState(() {
          score = data['score'] ?? 0;
          missing = data['missing_skills'] ?? "";
          suggestions = data['suggestions'] ?? "";
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  String levelText() {
    if (score >= 80) {
      return "Excellent Resume 🚀";
    }
    if (score >= 50) {
      return "Average Profile ⚠";
    }
    return "Needs Improvement ❌";
  }

  Color scoreColor() {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "ATS Resume Report",
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Username: ${widget.username}",
              ),
              pw.Text("Score: $score%"),
              pw.Text(
                "Status: ${levelText()}",
              ),
              pw.SizedBox(height: 20),
              pw.Text("Missing Skills:"),
              pw.Text(
                missing.isEmpty ? "None" : missing,
              ),
              pw.SizedBox(height: 20),
              pw.Text("AI Suggestions:"),
              pw.Text(
                suggestions.isEmpty ? "Your resume looks good." : suggestions,
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  Widget glow(
    double size,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget infoCard({
    required String title,
    required String text,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: glow(
              260,
              AppTheme.primary.withOpacity(
                0.22,
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(
              300,
              Colors.blue.withOpacity(
                0.10,
              ),
            ),
          ),
          SafeArea(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(
                                context,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "ATS Resume Score",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 28),
                        PremiumCard(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 60,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "$score%",
                                style: TextStyle(
                                  color: scoreColor(),
                                  fontSize: 54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                levelText(),
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        infoCard(
                          title: "Missing Skills",
                          text: missing.isEmpty ? "None 🎉" : missing,
                          icon: Icons.warning_amber,
                          colors: const [
                            Color(0xffFF6A00),
                            Color(0xffEE0979),
                          ],
                        ),
                        const SizedBox(height: 20),
                        infoCard(
                          title: "AI Suggestions",
                          text: suggestions.isEmpty
                              ? "Your resume looks good."
                              : suggestions,
                          icon: Icons.auto_awesome,
                          colors: const [
                            Color(0xff00C9FF),
                            Color(0xff92FE9D),
                          ],
                        ),
                        const SizedBox(height: 30),
                        PremiumButton(
                          text: "Download PDF Report",
                          icon: Icons.picture_as_pdf,
                          onTap: generatePDF,
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
