import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YoutubeAiVideosScreen extends StatefulWidget {
  final String username;
  final List<String> skills;

  const YoutubeAiVideosScreen({
    super.key,
    required this.username,
    this.skills = const [],
  });

  @override
  State<YoutubeAiVideosScreen> createState() =>
      _YoutubeAiVideosScreenState();
}

class _YoutubeAiVideosScreenState
    extends State<YoutubeAiVideosScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY 2'] ?? '';

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
        skills = [
          "Flutter",
          "DSA",
          "Aptitude",
          "HR Interview"
        ];
      }

      final prompt = """
Generate 12 best YouTube learning video recommendations for:
${skills.join(", ")}

Mix:
- technical interview prep
- aptitude
- HR interview
- project tutorials

Return ONLY JSON:

[
 {
   "title":"Flutter Interview Questions",
   "channel":"AI Recommended",
   "query":"flutter interview questions"
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
            {
              "role": "system",
              "content":
                  "Return only valid JSON video recommendations."
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

        allVideos =
            List<Map<String, dynamic>>.from(parsed);
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
        {
          "title": "Placement Aptitude",
          "channel": "Fallback",
          "query": "placement aptitude"
        },
        {
          "title": "HR Interview Questions",
          "channel": "Fallback",
          "query": "hr interview questions"
        }
      ];
    }

    filteredVideos = allVideos;

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void search(String query) {
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
    final url =
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';

    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _glow(
              250,
              Colors.deepPurple.withOpacity(0.25),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: _glow(
              260,
              Colors.purpleAccent.withOpacity(0.18),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius:
                                    BorderRadius.circular(
                                        18),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            "AI Videos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xffFF0000),
                              Color(0xff7B2FF7),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 70,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "AI Video Recommendations",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: searchController,
                        onChanged: search,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search videos...",
                          hintStyle:
                              const TextStyle(
                            color: Colors.white54,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    22),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          itemCount:
                              filteredVideos.length,
                          itemBuilder: (_, i) {
                            final video =
                                filteredVideos[i];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                      bottom: 16),
                              child: GestureDetector(
                                onTap: () =>
                                    openVideo(
                                  video['query'],
                                ),
                                child: Container(
                                  padding:
                                      const EdgeInsets
                                          .all(18),
                                  decoration:
                                      BoxDecoration(
                                    gradient:
                                        const LinearGradient(
                                      colors: [
                                        Color(
                                            0xff111C44),
                                        Color(
                                            0xff09122F),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                26),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .all(
                                                16),
                                        decoration:
                                            BoxDecoration(
                                          gradient:
                                              const LinearGradient(
                                            colors: [
                                              Colors.red,
                                              Colors
                                                  .pink,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      18),
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .play_arrow,
                                          color: Colors
                                              .white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              video[
                                                  'title'],
                                              style:
                                                  const TextStyle(
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize:
                                                    18,
                                              ),
                                            ),
                                            const SizedBox(
                                                height:
                                                    6),
                                            Text(
                                              video[
                                                  'channel'],
                                              style:
                                                  const TextStyle(
                                                color: Colors
                                                    .white70,
                                              ),
                                            ),
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