import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AptitudeScreen extends StatefulWidget {
  final String username;

  const AptitudeScreen({
    super.key,
    required this.username,
  });

  @override
  State<AptitudeScreen> createState() => _AptitudeScreenState();
}

class _AptitudeScreenState extends State<AptitudeScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY_BACKUP'] ?? '';

  List<Map<String, dynamic>> questions = [];

  int current = 0;
  int score = 0;
  bool finished = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAptitudeQuiz();
  }

  Future<void> loadAptitudeQuiz() async {
    setState(() {
      loading = true;
      finished = false;
      score = 0;
      current = 0;
      questions.clear();
    });

    try {
      final prompt = """
Generate exactly 10 aptitude multiple choice questions for placement preparation.

Include categories:
- Quantitative Aptitude
- Logical Reasoning
- Verbal Ability
- Data Interpretation
- Probability
- Time and Work
- Speed Distance

Rules:
- 4 options each
- one correct answer
- beginner to intermediate level
- return ONLY valid JSON array

Format:
[
 {
   "q":"question",
   "options":["A","B","C","D"],
   "answer":"correct option",
   "category":"category name"
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
                  "You are an aptitude quiz generator. Return only valid JSON."
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
              "q": "What is 20% of 250?",
              "options": ["25", "50", "75", "100"],
              "answer": "50",
              "category": "Quantitative"
            }
          ];
        });
      }
    }
  }

  void checkAnswer(String selected) {
    if (selected == questions[current]['answer']) {
      score++;
    }

    if (current < questions.length - 1) {
      setState(() {
        current++;
      });
    } else {
      setState(() {
        finished = true;
      });
    }
  }

  void restart() {
    loadAptitudeQuiz();
  }

  @override
  Widget build(BuildContext context) {
    final q = questions.isNotEmpty ? questions[current] : null;

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Aptitude Prep",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7B2FF7),
                          Color(0xff4A00E0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calculate,
                          color: Colors.white,
                          size: 70,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          finished
                              ? "Completed 🎉"
                              : "AI Aptitude Practice",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          finished
                              ? "Score: $score/${questions.length}"
                              : "Practice daily for placement success",
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
                  else if (!finished && q != null)
                    _quizCard(q)
                  else
                    _resultCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizCard(Map<String, dynamic> q) {
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
            q['category'],
            style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            q['q'],
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
                      padding: const EdgeInsets.all(16),
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

  Widget _resultCard() {
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
            "Final Score: $score/${questions.length}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: restart,
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