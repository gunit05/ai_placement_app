import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dashboard_screen.dart';
import '../theme/premium_ui.dart';

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

class _AiSkillOnboardingScreenState extends State<AiSkillOnboardingScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  final List<String> skills = [
    "C","C++","Java","Python","Dart","Flutter","Android","Kotlin",
    "HTML","CSS","JavaScript","React","Node.js","Web Development","DSA",
    "SQL","Database","Operating System","Computer Networks","Machine Learning",
    "Deep Learning","Data Science","AI","TensorFlow","Cloud","AWS","Docker",
    "Kubernetes","DevOps",
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

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> loadExistingSkills() async {
    try {
      final data = await Supabase.instance.client
          .from('user_skills')
          .select()
          .eq('username', widget.username)
          .maybeSingle();

      if (data != null) {
        selectedSkills
          ..clear()
          ..addAll(List<String>.from(data['skills'] ?? []));
        previewRole = data['recommended_role'] ?? "";
        salaryRange = data['salary_range'] ?? "";
        aiSuggestions = List<String>.from(data['ai_suggestions'] ?? []);
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> generateAIRecommendation() async {
    if (selectedSkills.isEmpty) {
      setState(() {
        previewRole = "";
        salaryRange = "";
        aiSuggestions = [];
      });
      return;
    }
    setState(() => loading = true);

    try {
      final prompt = """
Analyze these skills:
${selectedSkills.join(", ")}

Return ONLY valid JSON:
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
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": "Return only valid JSON."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiText = data['choices'][0]['message']['content'];
        aiText = aiText.replaceAll("```json", "").replaceAll("```", "").trim();
        final parsed = jsonDecode(aiText);

        previewRole = parsed['role'];
        salaryRange = parsed['salary'];
        aiSuggestions = List<String>.from(parsed['suggestions']);
      }
    } catch (_) {
      previewRole = "Software Engineer";
      salaryRange = "₹5 LPA - ₹12 LPA";
      aiSuggestions = ["Build projects","Practice DSA","Improve communication"];
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> saveSkills() async {
    if (selectedSkills.isEmpty) {
      showMsg("Select at least one skill");
      return;
    }
    setState(() => loading = true);

    try {
      await Supabase.instance.client.from('user_skills').upsert({
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
          builder: (_) => DashboardScreen(username: widget.username),
        ),
        (route) => false,
      );
    } catch (_) {
      showMsg("Failed to save profile");
    }

    if (mounted) setState(() => loading = false);
  }

  Widget skillChip(String skill) {
    final selected = selectedSkills.contains(skill);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selected ? selectedSkills.remove(skill) : selectedSkills.add(skill);
        });
        await generateAIRecommendation();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : (isDark ? Colors.white10 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          skill,
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget suggestionCard(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
            child: _glow(260, AppTheme.primary.withOpacity(0.22)),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(300, Colors.blue.withOpacity(0.10)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: PremiumCard(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Build AI Profile",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select your skills for personalized AI recommendations",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (previewRole.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewRole,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
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
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: skills.map(skillChip).toList(),
                        ),
                                              const SizedBox(height: 20),
                        ...aiSuggestions.map(suggestionCard),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: loading ? "Saving..." : "Save & Continue",
                      icon: Icons.arrow_forward,
                      onTap: loading ? () {} : saveSkills,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
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
