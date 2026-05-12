import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiSkillOnboardingScreen extends StatefulWidget {
  final String username;

  const AiSkillOnboardingScreen({
    super.key,
    required this.username,
  });

  @override
  State<AiSkillOnboardingScreen> createState() =>
      _AiSkillOnboardingScreenState();
}

class _AiSkillOnboardingScreenState
    extends State<AiSkillOnboardingScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  final List<String> skills = [
    "C",
    "C++",
    "Java",
    "Python",
    "Dart",
    "Flutter",
    "Android",
    "Kotlin",
    "HTML",
    "CSS",
    "JavaScript",
    "React",
    "Node.js",
    "Web Development",
    "DSA",
    "SQL",
    "Database",
    "Operating System",
    "Computer Networks",
    "Machine Learning",
    "Deep Learning",
    "Data Science",
    "AI",
    "TensorFlow",
    "Cloud",
    "AWS",
    "Docker",
    "Kubernetes",
    "DevOps",
  ];

  final List<String> selectedSkills = [];

  bool loading = false;
  String previewRole = "";
  String salaryRange = "";
  List<String> aiSuggestions = [];

  @override
  void initState() {
    super.initState();
    loadExistingSkills();
  }

  Future<void> loadExistingSkills() async {
    try {
      final res = Supabase.instance.client
          .from('user_skills')
          .select()
          .eq('username', widget.username)
          .maybeSingle();

      final data = await res;

      if (data != null) {
        selectedSkills.clear();
        selectedSkills.addAll(
          List<String>.from(data['skills'] ?? []),
        );

        previewRole =
            data['recommended_role'] ?? "";

        salaryRange =
            data['salary_range'] ?? "";

        aiSuggestions = List<String>.from(
          data['ai_suggestions'] ?? [],
        );
      }

      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> generateAIRecommendation() async {
    if (selectedSkills.isEmpty) {
      previewRole = "";
      salaryRange = "";
      aiSuggestions = [];

      if (mounted) setState(() {});
      return;
    }

    setState(() => loading = true);

    try {
      final prompt = """
Analyze these skills:
${selectedSkills.join(", ")}

Return ONLY JSON:

{
 "role":"Mobile App Developer",
 "salary":"₹6 LPA - ₹15 LPA",
 "suggestions":[
   "Learn Firebase",
   "Build projects",
   "Practice interviews"
 ]
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
                  "Return only valid JSON."
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

        previewRole = parsed['role'];
        salaryRange = parsed['salary'];
        aiSuggestions =
            List<String>.from(parsed['suggestions']);
      }
    } catch (_) {
      previewRole = "Software Engineer";
      salaryRange = "₹5 LPA - ₹12 LPA";

      aiSuggestions = [
        "Build projects",
        "Practice DSA",
        "Improve communication"
      ];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveSkills() async {
    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one skill"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await Supabase.instance.client
          .from('user_skills')
          .upsert({
        'username': widget.username,
        'skills': selectedSkills,
        'recommended_role': previewRole,
        'salary_range': salaryRange,
        'ai_suggestions': aiSuggestions,
      }, onConflict: 'username');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(username: widget.username),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget skillChip(String skill) {
    final selected = selectedSkills.contains(skill);

    return GestureDetector(
      onTap: () async {
        setState(() {
          selected
              ? selectedSkills.remove(skill)
              : selectedSkills.add(skill);
        });

        await generateAIRecommendation();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0xff7F00FF),
                    Color(0xffE100FF),
                  ],
                )
              : null,
          color: selected
              ? null
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          skill,
          style: TextStyle(
            color:
                selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget suggestionCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: Colors.amber,
          ),
          const SizedBox(width: 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff7B2FF7),
                    Color(0xff4A00E0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Text(
                "Build Your AI Profile 🚀",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (previewRole.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff30CFD0),
                        Color(0xff330867),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        previewRole,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        salaryRange,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          skills.map(skillChip).toList(),
                    ),
                    const SizedBox(height: 20),
                    ...aiSuggestions
                        .map(suggestionCard)
                        .toList(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      loading ? null : saveSkills,
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Save & Continue",
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