import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hire_hub/theme/premium_ui.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool loading = false;

  final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  final FocusNode focusNode = FocusNode();
  final List<Map<String, dynamic>> faq = [
    {
      "keywords": ["hello", "hi", "hey"],
      "answer": "Hello 👋 How can I help you today?"
    },
    {
      "keywords": ["job", "career"],
      "answer": "Go to Jobs section and apply for suitable opportunities."
    },
    {
      "keywords": ["resume"],
      "answer": "Upload your resume for AI analysis and ATS scoring."
    },
    {
      "keywords": ["interview"],
      "answer": "Use AI mock interview module for realistic practice."
    },
    {
      "keywords": ["skills"],
      "answer": "Add your skills for better AI recommendations."
    },
    {
      "keywords": ["who are you", "what can you do"],
      "answer":
          "I help with jobs, resumes, interviews, aptitude and career guidance."
    },
  ];

  String? getSmartReply(String userMsg) {
    final msg = userMsg.toLowerCase();

    int bestScore = 0;
    String bestAnswer = "";

    for (final item in faq) {
      int score = 0;

      for (final keyword in item["keywords"]) {
        if (msg.contains(keyword)) score++;
      }

      if (score > bestScore) {
        bestScore = score;
        bestAnswer = item["answer"];
      }
    }

    if (bestScore > 0) return bestAnswer;
    return null;
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty || loading) return;

    setState(() {
      messages.add({"user": text});
      loading = true;
    });

    controller.clear();
    scrollDown();

    final manualReply = getSmartReply(text);

    if (manualReply != null) {
      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      setState(() {
        messages.add({"bot": manualReply});
        loading = false;
      });

      scrollDown();
      return;
    }

    try {
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
                  "You are an AI placement assistant. Help with careers, jobs, interviews, resume review, aptitude and skill guidance. Keep responses concise and helpful."
            },
            {"role": "user", "content": text}
          ],
          "temperature": 0.7,
          "max_tokens": 500
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['choices'][0]['message']['content'];

        setState(() {
          messages.add({"bot": aiReply});
        });
      } else {
        setState(() {
          messages.add({"bot": "API Error ${response.statusCode}"});
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        messages.add({"bot": "Connection failed. Try again."});
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });

        scrollDown();
      }
    }
  }

  void scrollDown() {
    Future.delayed(
      const Duration(milliseconds: 150),
      () {
        if (!scrollController.hasClients) return;

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      },
    );
  }

  Widget buildBubble(String text, bool isBot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          gradient: isBot
              ? LinearGradient(
                  colors: isDark
                      ? [
                          AppTheme.darkCard,
                          AppTheme.darkCard2,
                        ]
                      : [
                          Colors.white,
                          const Color(0xffF4F6FB),
                        ],
                )
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(
              isBot ? 4 : 24,
            ),
            bottomRight: Radius.circular(
              isBot ? 24 : 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isBot ? Colors.black12 : AppTheme.primary.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isBot ? (isDark ? Colors.white : Colors.black87) : Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget quickChip(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        controller.text = text;
        sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: PremiumCard(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(width: 12),
            Text("AI is thinking..."),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 350),
          () {
            if (!scrollController.hasClients) return;

            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumScreen(
      title: "AI Assistant",
      subtitle: "Career guidance chatbot",
      icon: Icons.smart_toy_rounded,
      scrollable: false,
      child: Column(
        children: [
          if (messages.isEmpty)
            PremiumCard(
              child: Column(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/icon/ai_robot.png',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Ask AI Assistant",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Jobs, Resume, Interviews, Aptitude & Career Guidance",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      quickChip("Resume Help"),
                      quickChip("Find Jobs"),
                      quickChip("Interview Tips"),
                      quickChip("Career Advice"),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isBot = msg.containsKey("bot");

                return buildBubble(
                  msg.values.first,
                  isBot,
                );
              },
            ),
          ),
          if (loading) typingIndicator(),
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(.15),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(.05),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(.08)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => sendMessage(),
                            decoration: const InputDecoration(
                              hintText: "Message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                          onPressed: sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
