import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      'description': 'Print the largest number from given space-separated integers.',
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
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        submitCode();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
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

    final available =
        questions.where((q) => !askedQuestions.contains(q['id'])).toList();

    currentQuestion = available[random.nextInt(available.length)];
    askedQuestions.add(currentQuestion['id']);

    output = '';
    controller.text = starterCode();

    setState(() {});
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
# ${widget.username}, write your Python code here
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

  Future<void> runCode({bool checkAnswer = false}) async {
    setState(() {
      loading = true;
      output = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submissions/?base64_encoded=true&wait=false'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'language_id': languageId(),
          'source_code': base64Encode(utf8.encode(controller.text)),
          'stdin': base64Encode(utf8.encode(currentQuestion['input'])),
        }),
      );

      final token = jsonDecode(response.body)['token'];

      await Future.delayed(const Duration(seconds: 3));

      final result = await http.get(
        Uri.parse(
          '$baseUrl/submissions/$token?base64_encoded=true&fields=stdout,stderr,compile_output,status',
        ),
      );

      final data = jsonDecode(result.body);

      String resultText = '';

      if (data['stdout'] != null) {
        resultText = utf8.decode(base64Decode(data['stdout'])).trim();
      } else if (data['stderr'] != null) {
        resultText = utf8.decode(base64Decode(data['stderr']));
      } else if (data['compile_output'] != null) {
        resultText = utf8.decode(base64Decode(data['compile_output']));
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

      setState(() {
        output = resultText;
        loading = false;
      });
    } catch (e) {
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
    super.dispose();
  }

  Widget langChip(String lang) {
    return ChoiceChip(
      label: Text(lang),
      selected: selectedLang == lang,
      selectedColor: Colors.blue,
      backgroundColor: Colors.white10,
      labelStyle: const TextStyle(color: Colors.white),
      onSelected: (_) {
        setState(() {
          selectedLang = lang;
          controller.text = starterCode();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          '${widget.username} - DSA Coding Interview',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentQuestion['difficulty'],
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '⏳ ${formatTime()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                langChip('Python'),
                langChip('Java'),
                langChip('C'),
                langChip('C++'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentQuestion['description'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Input: ${currentQuestion['input']}',
                    style: const TextStyle(color: Colors.cyanAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: controller,
                  expands: true,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (output.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  output,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : () => runCode(),
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('Run'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : submitCode,
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : nextQuestion,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}