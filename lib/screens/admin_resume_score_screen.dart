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
            (data['score'] ?? "").toString();

        remarksController.text =
            data['remarks'] ?? "";
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

    final remarks =
        remarksController.text.trim();

    if (score == null ||
        score < 0 ||
        score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter valid score (0-100)",
          ),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await Supabase.instance.client
          .from('resume_scores')
          .upsert(
        {
          'username': widget.username,
          'score': score,
          'remarks': remarks,
          'ai_generated': false,
        },
        onConflict: 'username',
      );

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
          content: Text("Error: $e"),
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
      title: "Resume Score",
      subtitle: "Admin manual resume evaluation",
      icon: Icons.analytics,
      scrollable: false,
      child: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : Column(
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

                PremiumCard(
                  child: Column(
                    children: [
                      Text(
                        "$previewScore%",
                        style: TextStyle(
                          color: scoreColor(
                              previewScore),
                          fontSize: 54,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Live Preview Score",
                        style: TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),
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
                              "Enter score (0-100)",
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
                              "Enter remarks...",
                          hintStyle:
                              const TextStyle(
                            color:
                                Colors.white54,
                          ),
                          prefixIcon:
                              const Icon(
                            Icons.comment,
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
                    ],
                  ),
                ),

                const Spacer(),

                PremiumButton(
                  text: saving
                      ? "Saving..."
                      : "Save Score",
                  icon: Icons.save,
                  onTap:
                      saving ? () {} : saveScore,
                ),
              ],
            ),
    );
  }
}