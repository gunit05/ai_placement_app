import 'package:flutter/material.dart';

import 'notifications_screen.dart';
import 'resume_upload_screen.dart';
import 'jobs_screen.dart';
import 'application_history_screen.dart';
import 'chatbot_screen.dart';
import 'interview_screen.dart';
import 'coding_interview_screen.dart';
import 'ai_career_guidance_screen.dart';
import 'aptitude_screen.dart';
import 'quiz_screen.dart';
import 'youtube_ai_videos_screen.dart';

class HomePage extends StatelessWidget {
  final String username;
  final List<String> skills;

  const HomePage({
    super.key,
    required this.username,
    this.skills = const [],
  });

  void go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
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
            child: glow(
              260,
              Colors.deepPurple.withOpacity(0.25),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(
              300,
              Colors.purpleAccent.withOpacity(0.18),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // HEADER

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              "Hello, ${username.split('@')[0]} 👋",
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: 6),
                            const Text(
                              "AI Career Growth Dashboard",
                              style: TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          go(
                            context,
                            NotificationsScreen(
                              username:
                                  username,
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(
                                  14),
                          decoration:
                              BoxDecoration(
                            color: Colors.white10,
                            borderRadius:
                                BorderRadius
                                    .circular(18),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // HERO CARD

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(35),
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xff7B2FF7),
                          Color(0xff4A00E0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple
                              .withOpacity(0.45),
                          blurRadius: 35,
                          offset:
                              const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 75,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "AI Placement Assistant",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skills.isEmpty
                              ? "Smart placement preparation"
                              : "Skills: ${skills.take(3).join(", ")}",
                          textAlign:
                              TextAlign.center,
                          style: const TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Explore Features",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  GridView.count(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                    children: [
                      featureCard(
                        context,
                        Icons.upload_file,
                        "Resume Scanner",
                        "Improve your ATS resume",
                        [Colors.blue, Colors.cyan],
                        ResumeUploadScreen(
                          username: username,
                        ),
                      ),
                      featureCard(
                        context,
                        Icons.mic,
                        "Mock Interview",
                        "AI interview practice",
                        [
                          Colors.purple,
                          Colors.pink
                        ],
                        InterviewScreen(
                          username: username,
                        ),
                      ),
                      featureCard(
                        context,
                        Icons.calculate,
                        "Aptitude",
                        "Quant & reasoning prep",
                        [
                          Colors.orange,
                          Colors.red
                        ],
                        AptitudeScreen(
                          username: username,
                        ),
                      ),
                      featureCard(
                        context,
                        Icons.quiz,
                        "Quiz",
                        "Placement quiz challenge",
                        [
                          Colors.green,
                          Colors.teal
                        ],
                        QuizScreen(
                          username: username,
                        ),
                      ),
                      featureCard(
                        context,
                        Icons.play_circle_fill,
                        "AI Videos",
                        "Recommended YouTube videos",
                        [
                          Colors.red,
                          Colors.pink
                        ],
                        YoutubeAiVideosScreen(
                          username: username,
                          skills: skills,
                        ),
                      ),
                      featureCard(
                        context,
                        Icons.smart_toy,
                        "AI Chatbot",
                        "Ask doubts instantly",
                        [
                          Colors.indigo,
                          Colors.blue
                        ],
                        const ChatbotScreen(),
                      ),
                    
                      featureCard(
                        context,
                        Icons.history,
                        "History",
                        "Track applications",
                        [
                          Colors.teal,
                          Colors.cyan
                        ],
                        ApplicationHistoryScreen(
                          username: username,
                        ),
                      ),
                      featureCard(
                        context,
                        Icons.psychology,
                        "Career AI",
                        "AI career roadmap",
                        [
                          Colors.cyan,
                          Colors.blue
                        ],
                        AICareerGuidanceScreen(
                          username: username,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    List<Color> colors,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () => go(context, page),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(
            colors: [
              Color(0xff111C44),
              Color(0xff09122F),
            ],
          ),
          borderRadius:
              BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color:
                  colors.first.withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                ),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget glow(double size, Color color) {
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