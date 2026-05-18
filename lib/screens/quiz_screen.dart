import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../theme/premium_ui.dart';

class QuizScreen extends StatefulWidget {
  final String username;

  const QuizScreen({
    super.key,
    required this.username,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY_BACKUP'] ?? '';

  List<Map<String, dynamic>> questions = [];
  List<String> userSkills = [];

  int index = 0;
  int score = 0;
  bool finished = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    setState(() {
      loading = true;
      finished = false;
      score = 0;
      index = 0;
      questions.clear();
    });

    try {
      final res = await Supabase.instance.client
          .from('user_skills')
          .select()
          .eq('username', widget.username)
          .maybeSingle();

      if (res != null && res['skills'] != null) {
        userSkills = List<String>.from(
          res['skills'],
        );
      }

      if (userSkills.isEmpty) {
        userSkills = [
          "Java",
          "Python",
          "DSA",
          "Operating System",
          "Database",
        ];
      }

      final prompt = """
Generate exactly 10 technical multiple choice interview questions based on these skills:
${userSkills.join(", ")}

Rules:
- Technical questions only
- 4 options each
- one correct answer
- beginner to intermediate difficulty
- return ONLY valid JSON array

Format:
[
 {
   "q":"question",
   "options":["A","B","C","D"],
   "answer":"correct option"
 }
]
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
            {"role": "system", "content": "You return only valid JSON."},
            {
              "role": "user",
              "content": prompt,
            }
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String aiText = data['choices'][0]['message']['content'];

        aiText = aiText.replaceAll(
          "```json",
          "",
        );
        aiText = aiText.replaceAll(
          "```",
          "",
        );
        aiText = aiText.trim();

        final parsed = jsonDecode(aiText);

        questions = List<Map<String, dynamic>>.from(
          parsed,
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      questions = [
        {
          "q": "What is OOP?",
          "options": [
            "Object Oriented Programming",
            "Operating Output Process",
            "Object Output Program",
            "None"
          ],
          "answer": "Object Oriented Programming"
        }
      ];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void checkAnswer(String selected) {
    if (selected == questions[index]['answer']) {
      score++;
    }

    if (index < questions.length - 1) {
      setState(() => index++);
    } else {
      setState(() => finished = true);
    }
  }

  void restartQuiz() {
    loadQuiz();
  }

  Widget quizView() {
    final q = questions[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q${index + 1}. ${q['q']}",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          ...(q['options'] as List)
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: PremiumButton(
                    text: option.toString(),
                    icon: Icons.arrow_forward,
                    onTap: () => checkAnswer(
                      option.toString(),
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget resultView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 80,
          ),
          const SizedBox(height: 18),
          Text(
            "Score: $score / ${questions.length}",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Keep practicing to improve 🚀",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          PremiumButton(
            text: "Generate New Quiz",
            icon: Icons.refresh,
            onTap: restartQuiz,
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
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Technical Quiz",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.code,
                          color: Colors.white,
                          size: 70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          finished ? "Quiz Completed 🎉" : "AI Technical Quiz",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          finished
                              ? "${widget.username}, score: $score/${questions.length}"
                              : "Based on your selected skills",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    )
                  else if (!finished)
                    quizView()
                  else
                    resultView(),
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
