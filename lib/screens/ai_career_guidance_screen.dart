import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AICareerGuidanceScreen extends StatefulWidget {
  final String username;

  const AICareerGuidanceScreen({
    super.key,
    required this.username,
  });

  @override
  State<AICareerGuidanceScreen> createState() =>
      _AICareerGuidanceScreenState();
}

class _AICareerGuidanceScreenState
    extends State<AICareerGuidanceScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  bool loading = true;

  List skills = [];
  String role = "";
  List<String> roadmap = [];
  List<String> missingSkills = [];
  List<String> certifications = [];
  List<String> projects = [];
  List<String> interviewTips = [];
  String salaryRange = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final res = await Supabase.instance.client
          .from('user_skills')
          .select()
          .eq('username', widget.username)
          .maybeSingle();

      if (res != null) {
        skills = res['skills'] ?? [];
        role =
            res['recommended_role'] ?? "Software Engineer";
      }

      await generateAIPlan();
    } catch (_) {
      fallbackPlan();
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> generateAIPlan() async {
    try {
      final prompt = """
Generate career guidance for:

Role: $role
Skills: ${skills.join(", ")}

Return ONLY JSON:

{
 "missing_skills":["skill1"],
 "roadmap":["step1"],
 "certifications":["cert1"],
 "projects":["project1"],
 "interview_tips":["tip1"],
 "salary_range":"₹6 LPA - ₹15 LPA"
}
""";

      final response = await http.post(
        Uri.parse(
          'https://api.groq.com/openai/v1/chat/completions',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "Return only valid JSON career guidance."
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String aiText =
            data['choices'][0]['message']['content'];

        aiText = aiText.replaceAll("```json", "");
        aiText = aiText.replaceAll("```", "");
        aiText = aiText.trim();

        final parsed = jsonDecode(aiText);

        missingSkills =
            List<String>.from(parsed['missing_skills']);
        roadmap = List<String>.from(parsed['roadmap']);
        certifications =
            List<String>.from(parsed['certifications']);
        projects = List<String>.from(parsed['projects']);
        interviewTips =
            List<String>.from(parsed['interview_tips']);
        salaryRange = parsed['salary_range'];
      } else {
        fallbackPlan();
      }
    } catch (_) {
      fallbackPlan();
    }
  }

  void fallbackPlan() {
    missingSkills = [
      "DSA",
      "System Design",
      "API Integration"
    ];

    roadmap = [
      "Master fundamentals",
      "Build real projects",
      "Practice coding interviews",
      "Learn system design",
      "Apply for internships"
    ];

    certifications = [
      "AWS Cloud Practitioner",
      "Flutter Certification"
    ];

    projects = [
      "E-commerce App",
      "Chatbot App",
      "AI Resume Analyzer"
    ];

    interviewTips = [
      "Practice mock interviews",
      "Improve communication",
      "Solve coding questions daily"
    ];

    salaryRange = "₹5 LPA - ₹12 LPA";
  }

  Widget glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff7B2FF7),
            Color(0xff4A00E0),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget listCard(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff111C44),
            Color(0xff09122F),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listSection(
      String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        const SizedBox(height: 14),
        ...items
            .asMap()
            .entries
            .map((e) => listCard(e.value, e.key)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "AI Career Guidance",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff30CFD0),
                          Color(0xff330867),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recommended Career",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          salaryRange,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  sectionTitle("Your Skills"),
                  const SizedBox(height: 14),
                  glassCard(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skills
                          .map((e) =>
                              skillChip(e.toString()))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  sectionTitle("Missing Skills"),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        missingSkills.map(skillChip).toList(),
                  ),
                  const SizedBox(height: 28),
                  listSection("AI Roadmap", roadmap),
                  const SizedBox(height: 20),
                  listSection(
                      "Recommended Certifications",
                      certifications),
                  const SizedBox(height: 20),
                  listSection(
                      "Project Suggestions", projects),
                  const SizedBox(height: 20),
                  listSection(
                      "Interview Tips", interviewTips),
                ],
              ),
            ),
    );
  }
}