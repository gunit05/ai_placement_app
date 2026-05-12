import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        userSkills = List<String>.from(res['skills']);
      }

      if (userSkills.isEmpty) {
        userSkills = ["Java", "Python", "DSA", "Operating System", "Database"];
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
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
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
                  "You are a technical interview quiz generator that returns only JSON."
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiText = data['choices'][0]['message']['content'];

        aiText = aiText.replaceAll("```json", "");
        aiText = aiText.replaceAll("```", "");
        aiText = aiText.trim();

        final parsed = jsonDecode(aiText);

        questions = List<Map<String, dynamic>>.from(parsed);

        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      } else {
        throw Exception("API Error ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
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
        });
      }
    }
  }

  void checkAnswer(String selected) {
    if (selected == questions[index]['answer']) {
      score++;
    }

    if (index < questions.length - 1) {
      setState(() {
        index++;
      });
    } else {
      setState(() {
        finished = true;
      });
    }
  }

  void restartQuiz() {
    loadQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _glow(
              260,
              Colors.deepPurple.withOpacity(0.25),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(
              300,
              Colors.purpleAccent.withOpacity(0.18),
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
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Technical Quiz",
                        style: TextStyle(
                          color: Colors.white,
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
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7B2FF7),
                          Color(0xff4A00E0),
                        ],
                      ),
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
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
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

  Widget quizView() {
    final q = questions[index];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff111C44),
            Color(0xff09122F),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q${index + 1}. ${q['q']}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...(q['options'] as List)
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GestureDetector(
                    onTap: () => checkAnswer(option.toString()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff7B2FF7),
                            Color(0xff4A00E0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        option.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    return Container(
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
      ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Keep practicing to improve 🚀",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: restartQuiz,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff7B2FF7),
                    Color(0xff4A00E0),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Generate New Quiz",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
