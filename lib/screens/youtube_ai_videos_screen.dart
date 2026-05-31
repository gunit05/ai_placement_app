import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/premium_ui.dart';
import '../theme/theme_controller.dart';

class YoutubeAiVideosScreen extends StatefulWidget {
  final String username;
  final List<String> skills;

  const YoutubeAiVideosScreen({
    super.key,
    required this.username,
    this.skills = const [],
  });

  @override
  State<YoutubeAiVideosScreen> createState() => _YoutubeAiVideosScreenState();
}

class _YoutubeAiVideosScreenState extends State<YoutubeAiVideosScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY_BACKUP'] ?? '';
  final supabase = Supabase.instance.client;
  final searchController = TextEditingController();

  List<Map<String, dynamic>> allVideos = [];
  List<Map<String, dynamic>> filteredVideos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      List<String> skills = widget.skills;
      if (skills.isEmpty) {
        final res = await supabase
            .from('user_skills')
            .select()
            .eq('username', widget.username)
            .maybeSingle();
        if (res != null && res['skills'] != null) {
          skills = List<String>.from(res['skills']);
        }
      }
      if (skills.isEmpty) {
        skills = ["Flutter", "DSA", "Aptitude", "HR Interview"];
      }

      final prompt = """
Generate 10 YouTube learning video recommendations for:
${skills.join(", ")}
Return ONLY valid JSON.
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
        allVideos = List<Map<String, dynamic>>.from(parsed);
      } else {
        throw Exception();
      }
    } catch (_) {
      allVideos = [
        {
          "title": "Flutter Interview Questions",
          "channel": "Fallback",
          "query": "flutter interview questions"
        },
        {
          "title": "DSA Interview Prep",
          "channel": "Fallback",
          "query": "dsa interview preparation"
        },
      ];
    }

    filteredVideos = allVideos;
    if (mounted) setState(() => loading = false);
  }

  Future<void> search(String query) async {
    setState(() {
      filteredVideos = allVideos.where((video) {
        return video['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            video['channel']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> openVideo(String query) async {
  try {
    final youtubeAppUri = Uri.parse(
      'youtube://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
    );

    final youtubeWebUri = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
    );

    // First try YouTube app
    if (await canLaunchUrl(youtubeAppUri)) {
      await launchUrl(
        youtubeAppUri,
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    // Fallback to browser
    await launchUrl(
      youtubeWebUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('YouTube Launch Error: $e');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open YouTube: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text("AI Videos",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: search,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Search videos...",
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45),
                  prefixIcon: Icon(Icons.search,
                      color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.black12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredVideos.length,
                      itemBuilder: (_, i) {
                        final video = filteredVideos[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => openVideo(video['query']),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkCard
                                    : AppTheme.lightCard,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.aiGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.play_arrow,
                                        color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(video['title'],
                                            style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(video['channel'],
                                            style: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
