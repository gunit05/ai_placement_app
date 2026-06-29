import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hire_hub/theme/premium_ui.dart';

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
Generate exactly 10 aptitude MCQ questions.

Categories:
- Quantitative Aptitude
- Logical Reasoning
- Verbal Ability
- Data Interpretation
- Probability
- Time and Work
- Speed Distance

Return ONLY valid JSON:
[
 {
   "q":"question",
   "options":["A","B","C","D"],
   "answer":"correct option",
   "category":"category"
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
            {"role": "system", "content": "Return only valid JSON."},
            {"role": "user", "content": prompt}
          ]
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
      } else {
        throw Exception();
      }
    } catch (_) {
      questions = [
        {
          "q": "What is 20% of 250?",
          "options": ["25", "50", "75", "100"],
          "answer": "50",
          "category": "Quantitative"
        }
      ];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void checkAnswer(String selected) {
    if (selected == questions[current]['answer']) {
      score++;
    }

    if (current < questions.length - 1) {
      setState(() => current++);
    } else {
      setState(() => finished = true);
    }
  }

  Widget optionButton(String option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => checkAnswer(option),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            option,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget quizCard(Map<String, dynamic> q) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q['category'],
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            q['q'],
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          ...(q['options'] as List)
              .map((e) => optionButton(e.toString()))
              .toList(),
        ],
      ),
    );
  }

  Widget resultCard() {
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
            "Final Score: $score/${questions.length}",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          PremiumButton(
            text: "Generate New Quiz",
            icon: Icons.refresh,
            onTap: loadAptitudeQuiz,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions.isNotEmpty ? questions[current] : null;

    return PremiumScreen(
      title: "Aptitude Prep",
      subtitle: "AI-generated placement practice",
      icon: Icons.calculate,
      scrollable: true,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 70,
                ),
                const SizedBox(height: 14),
                Text(
                  finished ? "Completed 🎉" : "AI Aptitude Practice",
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
          const SizedBox(height: 26),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              ),
            )
          else if (!finished && q != null)
            quizCard(q)
          else
            resultCard(),
        ],
      ),
    );
  }
}
