import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class ProfileAnalyticsScreen extends StatefulWidget {
  final String username;

  const ProfileAnalyticsScreen({
    super.key,
    required this.username,
  });

  @override
  State<ProfileAnalyticsScreen> createState() =>
      _ProfileAnalyticsScreenState();
}

class _ProfileAnalyticsScreenState
    extends State<ProfileAnalyticsScreen> {
  String role = "";
  List<String> skills = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final res = await Supabase.instance.client
          .from('user_skills')
          .select('recommended_role, skills')
          .eq('username', widget.username)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        role = res?['recommended_role'] ?? "Not Assigned";
        skills = List<String>.from(res?['skills'] ?? []);
        loading = false;
      });
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  double skillScore() {
    return (skills.length / 12).clamp(0.0, 1.0);
  }

  String levelText(double score) {
    if (score > 0.8) return "Expert 🚀";
    if (score > 0.5) return "Intermediate 🔥";
    return "Beginner 🌱";
  }

  Color scoreColor(double score) {
    if (score > 0.8) return Colors.green;
    if (score > 0.5) return Colors.orange;
    return Colors.red;
  }

  List<Color> chipColors(int index) {
    final colors = [
      [Colors.purple, Colors.deepPurple],
      [Colors.blue, Colors.cyan],
      [Colors.orange, Colors.red],
      [Colors.pink, Colors.purple],
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final score = skillScore();

    return PremiumScreen(
      title: "Profile Analytics",
      subtitle: "AI skill insights & recommendations",
      icon: Icons.analytics,
      scrollable: true,
      actions: [
        IconButton(
          onPressed: loadData,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ],
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : Column(
              children: [
                PremiumCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.secondary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              role,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                PremiumCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Skill Strength",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: score,
                          minHeight: 16,
                          backgroundColor:
                              Colors.white24,
                          valueColor:
                              AlwaysStoppedAnimation(
                            scoreColor(score),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(score * 100).toInt()}%",
                            style: TextStyle(
                              color: scoreColor(score),
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            levelText(score),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                PremiumCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Insights",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        skills.length < 5
                            ? "⚠ Add more skills to improve profile visibility."
                            : "✅ Strong profile for recruiters.",
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Recommended focus: $role advanced concepts",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                PremiumCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Skills",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      skills.isEmpty
                          ? const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(20),
                                child: Text(
                                  "No skills added",
                                  style: TextStyle(
                                    color:
                                        Colors.white70,
                                  ),
                                ),
                              ),
                            )
                          : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: skills
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        gradient:
                                            LinearGradient(
                                          colors:
                                              chipColors(
                                            e.key,
                                          ),
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    22),
                                      ),
                                      child: Text(
                                        e.value,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}