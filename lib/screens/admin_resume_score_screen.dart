import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class AdminResumeScoreScreen extends StatefulWidget {
  final String username;

  const AdminResumeScoreScreen({
    super.key,
    required this.username,
  });

  @override
  State<AdminResumeScoreScreen> createState() =>
      _AdminResumeScoreScreenState();
}

class _AdminResumeScoreScreenState
    extends State<AdminResumeScoreScreen> {
  final scoreController = TextEditingController();
  final remarksController = TextEditingController();

  bool saving = false;
  bool loading = true;

  int aiScore = 0;
  String aiSuggestions = "";
  String strengths = "";
  String missingSkills = "";

  @override
  void initState() {
    super.initState();
    loadExistingScore();
  }

  Future<void> loadExistingScore() async {
    try {
      final data = await Supabase.instance.client
          .from('resume_scores')
          .select()
          .eq('username', widget.username)
          .maybeSingle();

      if (data != null) {
        scoreController.text =
            (data['score'] ?? 0).toString();

        remarksController.text =
            data['remarks'] ?? "";

        aiScore =
            data['ai_score'] ?? 0;

        aiSuggestions =
            data['ai_suggestions'] ?? "";

        strengths =
            data['strengths'] ?? "";

        missingSkills =
            data['missing_skills'] ?? "";
      }
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveScore() async {
    final score =
        int.tryParse(scoreController.text.trim());

    if (score == null ||
        score < 0 ||
        score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter valid score"),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await Supabase.instance.client
          .from('resume_scores')
          .update({
        'score': score,
        'remarks': remarksController.text.trim(),
        'admin_override': true,
      })
          .eq('username', widget.username);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Saved Successfully ✅",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }

    if (mounted) {
      setState(() => saving = false);
    }
  }

  Color scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget infoCard({
    required String title,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text.isEmpty ? "-" : text,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scoreController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewScore =
        int.tryParse(scoreController.text) ?? 0;

    return PremiumScreen(
      title: "Hybrid ATS Review",
      subtitle: "Groq AI + Manual Review",
      icon: Icons.analytics,
      child: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  PremiumCard(
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(
                                  16),
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.purple,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.username,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: PremiumCard(
                          child: Column(
                            children: [
                              Text(
                                "$previewScore%",
                                style: TextStyle(
                                  color:
                                      scoreColor(
                                          previewScore),
                                  fontSize: 42,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Manual / Final Score",
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: PremiumCard(
                          child: Column(
                            children: [
                              Text(
                                "$aiScore%",
                                style: TextStyle(
                                  color:
                                      scoreColor(
                                          aiScore),
                                  fontSize: 42,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Groq AI Score",
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  infoCard(
                    title: "Missing Skills",
                    text: missingSkills,
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 16),

                  infoCard(
                    title: "AI Strengths",
                    text: strengths,
                    icon: Icons.star,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 16),

                  infoCard(
                    title: "Groq Suggestions",
                    text: aiSuggestions,
                    icon: Icons.auto_awesome,
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 18),

                  PremiumCard(
                    child: Column(
                      children: [
                        TextField(
                          controller:
                              scoreController,
                          keyboardType:
                              TextInputType
                                  .number,
                          onChanged: (_) =>
                              setState(() {}),
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),
                          decoration:
                              InputDecoration(
                            hintText:
                                "Enter final manual score",
                            hintStyle:
                                const TextStyle(
                              color:
                                  Colors.white54,
                            ),
                            prefixIcon:
                                const Icon(
                              Icons.score,
                              color: Colors
                                  .white70,
                            ),
                            filled: true,
                            fillColor:
                                Colors.white10,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller:
                              remarksController,
                          maxLines: 5,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),
                          decoration:
                              InputDecoration(
                            hintText:
                                "Admin remarks...",
                            hintStyle:
                                const TextStyle(
                              color:
                                  Colors.white54,
                            ),
                            filled: true,
                            fillColor:
                                Colors.white10,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  PremiumButton(
                    text: saving
                        ? "Saving..."
                        : "Save Final Review",
                    icon: Icons.save,
                    onTap:
                        saving ? () {} : saveScore,
                  ),
                ],
              ),
            ),
    );
  }
}