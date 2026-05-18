import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/premium_ui.dart';

class CodingInterviewScreen extends StatefulWidget {
  final String username;

  const CodingInterviewScreen({
    super.key,
    required this.username,
  });

  @override
  State<CodingInterviewScreen> createState() => _CodingInterviewScreenState();
}

class _CodingInterviewScreenState extends State<CodingInterviewScreen> {
  static const String baseUrl = 'https://ce.judge0.com';

  final TextEditingController controller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final Random random = Random();

  Timer? timer;
  int timeLeft = 1800;

  String selectedLang = 'Python';
  String output = '';
  bool loading = false;

  late Map<String, dynamic> currentQuestion;
  final Set<int> askedQuestions = {};

  final List<Map<String, dynamic>> questions = [
    {
      'id': 1,
      'title': 'Find Maximum Number',
      'difficulty': 'Easy',
      'description':
          'Print the largest number from given space-separated integers.',
      'input': '3 5 1 9 2',
      'expected': '9',
    },
    {
      'id': 2,
      'title': 'Sum of Numbers',
      'difficulty': 'Easy',
      'description': 'Print sum of all numbers.',
      'input': '1 2 3 4',
      'expected': '10',
    },
    {
      'id': 3,
      'title': 'Count Even Numbers',
      'difficulty': 'Easy',
      'description': 'Count total even numbers.',
      'input': '1 2 3 4 6',
      'expected': '3',
    },
    {
      'id': 4,
      'title': 'Reverse String',
      'difficulty': 'Easy',
      'description': 'Reverse the given string.',
      'input': 'hello',
      'expected': 'olleh',
    },
    {
      'id': 5,
      'title': 'Factorial',
      'difficulty': 'Easy',
      'description': 'Print factorial of given number.',
      'input': '5',
      'expected': '120',
    },
    {
      'id': 6,
      'title': 'Palindrome Check',
      'difficulty': 'Easy',
      'description': 'Print YES if palindrome else NO.',
      'input': 'madam',
      'expected': 'YES',
    },
    {
      'id': 7,
      'title': 'Smallest Number',
      'difficulty': 'Easy',
      'description': 'Find smallest number.',
      'input': '8 3 6 2 9',
      'expected': '2',
    },
  ];

  @override
  void initState() {
    super.initState();
    nextQuestion();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (timeLeft <= 0) {
          t.cancel();
          submitCode();
        } else {
          if (mounted) {
            setState(() {
              timeLeft--;
            });
          }
        }
      },
    );
  }

  String formatTime() {
    final min = timeLeft ~/ 60;
    final sec = timeLeft % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  void nextQuestion() {
    if (askedQuestions.length == questions.length) {
      askedQuestions.clear();
    }

    final available = questions
        .where(
          (q) => !askedQuestions.contains(q['id']),
        )
        .toList();

    currentQuestion = available[random.nextInt(available.length)];

    askedQuestions.add(currentQuestion['id']);

    output = '';
    controller.text = starterCode();

    if (mounted) {
      setState(() {});
    }
  }

  String starterCode() {
    switch (selectedLang) {
      case 'Java':
        return '''
import java.util.*;

public class Main {
  public static void main(String[] args) {

  }
}
''';

      case 'C':
        return '''
#include <stdio.h>

int main() {

  return 0;
}
''';

      case 'C++':
        return '''
#include <iostream>
using namespace std;

int main() {

  return 0;
}
''';

      default:
        return '''
# ${widget.username}, write Python code here

print()
''';
    }
  }

  int languageId() {
    switch (selectedLang) {
      case 'Java':
        return 62;
      case 'C':
        return 50;
      case 'C++':
        return 54;
      default:
        return 71;
    }
  }

  Future<void> runCode({
    bool checkAnswer = false,
  }) async {
    setState(() {
      loading = true;
      output = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/submissions/?base64_encoded=true&wait=false',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'language_id': languageId(),
          'source_code': base64Encode(
            utf8.encode(controller.text),
          ),
          'stdin': base64Encode(
            utf8.encode(currentQuestion['input']),
          ),
        }),
      );

      final token = jsonDecode(response.body)['token'];

      await Future.delayed(
        const Duration(seconds: 3),
      );

      final result = await http.get(
        Uri.parse(
          '$baseUrl/submissions/$token?base64_encoded=true&fields=stdout,stderr,compile_output,status',
        ),
      );

      final data = jsonDecode(result.body);

      String resultText = '';

      if (data['stdout'] != null) {
        resultText = utf8
            .decode(
              base64Decode(data['stdout']),
            )
            .trim();
      } else if (data['stderr'] != null) {
        resultText = utf8.decode(
          base64Decode(data['stderr']),
        );
      } else if (data['compile_output'] != null) {
        resultText = utf8.decode(
          base64Decode(data['compile_output']),
        );
      } else {
        resultText = 'No output';
      }

      if (checkAnswer) {
        if (resultText.trim() == currentQuestion['expected'].trim()) {
          resultText = '$resultText\n\n✅ Correct Answer';
        } else {
          resultText =
              '$resultText\n\n❌ Wrong Answer\nExpected: ${currentQuestion['expected']}';
        }
      }

      if (!mounted) return;

      setState(() {
        output = resultText;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        output = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<void> submitCode() async {
    await runCode(checkAnswer: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Widget langChip(String lang) {
    final selected = selectedLang == lang;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLang = lang;
          controller.text = starterCode();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: PremiumButton(
        text: text,
        icon: icon,
        onTap: loading ? () {} : onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "Coding Interview",
      subtitle: "AI coding challenge practice",
      icon: Icons.code,
      scrollable: false,
      child: Column(
        children: [
          PremiumCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currentQuestion['difficulty'],
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "⏳ ${formatTime()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              langChip('Python'),
              langChip('Java'),
              langChip('C'),
              langChip('C++'),
            ],
          ),
          const SizedBox(height: 14),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentQuestion['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Input: ${currentQuestion['input']}',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white12,
                ),
              ),
              child: TextField(
                controller: controller,
                expands: true,
                maxLines: null,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (output.isNotEmpty)
            PremiumCard(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Text(
                  output,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(
                bottom: 14,
              ),
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            ),
          Row(
            children: [
              actionButton(
                text: "Run",
                icon: Icons.play_arrow,
                onTap: () => runCode(),
              ),
              const SizedBox(width: 10),
              actionButton(
                text: "Submit",
                icon: Icons.check_circle,
                onTap: submitCode,
              ),
              const SizedBox(width: 10),
              actionButton(
                text: "Next",
                icon: Icons.skip_next,
                onTap: nextQuestion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
