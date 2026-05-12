import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  int score = 0;
  String missing = "";
  String suggestions = "";

  @override
  void initState() {
    super.initState();
    fetchScore();
  }

  Future<void> fetchScore() async {
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
  }

  String levelText() {
    if (score >= 80) return "Excellent Resume 🚀";
    if (score >= 50) return "Average Profile ⚠";
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
        build: (_) => pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "ATS Resume Report",
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Username: ${widget.username}"),
            pw.Text("Score: $score%"),
            pw.Text("Status: ${levelText()}"),
            pw.SizedBox(height: 20),
            pw.Text("Missing Skills:"),
            pw.Text(missing.isEmpty ? "None" : missing),
            pw.SizedBox(height: 20),
            pw.Text("Suggestions:"),
            pw.Text(suggestions),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  Widget gradientCard({
    required List<Color> colors,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "ATS Resume Score 📊",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  gradientCard(
                    colors: const [
                      Color(0xff7B2FF7),
                      Color(0xffE940FF),
                    ],
                    child: Column(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 50,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "$score%",
                          style: TextStyle(
                            color: scoreColor(),
                            fontSize: 52,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          levelText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  gradientCard(
                    colors: const [
                      Color(0xffFF6A00),
                      Color(0xffEE0979),
                    ],
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Missing Skills",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          missing.isEmpty
                              ? "None 🎉"
                              : missing,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  gradientCard(
                    colors: const [
                      Color(0xff00C9FF),
                      Color(0xff92FE9D),
                    ],
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AI Suggestions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          suggestions.isEmpty
                              ? "Your resume looks good."
                              : suggestions,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: generatePDF,
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Download PDF Report",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}