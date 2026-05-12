import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

class InterviewResultScreen extends StatelessWidget {
  final int score;
  final String username;

  const InterviewResultScreen({
    super.key,
    required this.score,
    required this.username,
  });

  String getFeedback() {
    if (score >= 80) return "Excellent! You're Job Ready 🚀";
    if (score >= 60) return "Good Performance 👍";
    if (score >= 40) return "Average Performance ⚠";
    return "Needs Improvement ❌";
  }

  String getImprovement() {
    if (score >= 80) return "Keep practicing advanced interviews.";
    if (score >= 60) return "Improve fluency and confidence.";
    if (score >= 40) return "Work on answer clarity.";
    return "Practice communication daily.";
  }

  List<BarChartGroupData> getChart() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: score.toDouble(),
            width: 28,
            gradient: const LinearGradient(
              colors: [
                Color(0xff7B2FF7),
                Color(0xffE940FF),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    ];
  }

  Future<void> downloadPDF() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "AI Interview Report",
                style: pw.TextStyle(fontSize: 26),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Candidate: $username"),
              pw.Text("Score: $score%"),
              pw.SizedBox(height: 20),
              pw.Text("Feedback: ${getFeedback()}"),
              pw.SizedBox(height: 10),
              pw.Text("Improvement: ${getImprovement()}"),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
    );
  }

  Color scoreColor() {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.orangeAccent;
    if (score >= 40) return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff7B2FF7),
                      Color(0xffE940FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
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

              const Text(
                "Interview Completed",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                username,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff111C44),
                      Color(0xff09122F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.deepPurple.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "$score%",
                      style: TextStyle(
                        color: scoreColor(),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      getFeedback(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                height: 240,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    borderData:
                        FlBorderData(show: false),
                    titlesData:
                        FlTitlesData(show: false),
                    gridData:
                        FlGridData(show: false),
                    barGroups: getChart(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff30CFD0),
                      Color(0xff330867),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Improvement Suggestions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      getImprovement(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
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
                  onPressed: downloadPDF,
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Download Report",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.white24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}