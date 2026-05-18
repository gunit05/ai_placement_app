import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/premium_ui.dart';

class InterviewResultScreen extends StatelessWidget {
  final int score;
  final String username;

  const InterviewResultScreen({
    super.key,
    required this.score,
    required this.username,
  });

  String getFeedback() {
    if (score >= 80) {
      return "Excellent! You're Job Ready 🚀";
    }
    if (score >= 60) {
      return "Good Performance 👍";
    }
    if (score >= 40) {
      return "Average Performance ⚠";
    }
    return "Needs Improvement ❌";
  }

  String getImprovement() {
    if (score >= 80) {
      return "Keep practicing advanced interviews.";
    }
    if (score >= 60) {
      return "Improve fluency and confidence.";
    }
    if (score >= 40) {
      return "Work on answer clarity.";
    }
    return "Practice communication daily.";
  }

  Color scoreColor() {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.orangeAccent;
    if (score >= 40) return Colors.amber;
    return Colors.redAccent;
  }

  List<BarChartGroupData> getChart() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: score.toDouble(),
            width: 32,
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    ];
  }

  Future<void> downloadPDF() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (_) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "AI Interview Report",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text("Candidate: $username"),
                pw.Text("Score: $score%"),
                pw.SizedBox(height: 20),
                pw.Text("Feedback: ${getFeedback()}"),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Improvement: ${getImprovement()}",
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
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
            child: _glow(
              260,
              AppTheme.primary.withOpacity(0.22),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(
              300,
              Colors.blue.withOpacity(0.10),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Interview Completed",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  PremiumCard(
                    child: Column(
                      children: [
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
                          getFeedback(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PremiumCard(
                    child: SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          maxY: 100,
                          borderData: FlBorderData(
                            show: false,
                          ),
                          titlesData: FlTitlesData(
                            show: false,
                          ),
                          gridData: FlGridData(
                            show: false,
                          ),
                          barGroups: getChart(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.aiGradient,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Improvement Suggestions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          getImprovement(),
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: "Download Report PDF",
                      icon: Icons.picture_as_pdf,
                      onTap: downloadPDF,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(
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
}
