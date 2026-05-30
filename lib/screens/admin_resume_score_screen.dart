import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class AdminResumeScoreScreen extends StatefulWidget {
  final String username;
  const AdminResumeScoreScreen({super.key, required this.username});

  @override
  State<AdminResumeScoreScreen> createState() => _AdminResumeScoreScreenState();
}

class _AdminResumeScoreScreenState extends State<AdminResumeScoreScreen> {
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
        scoreController.text = (data['score'] ?? 0).toString();
        remarksController.text = data['remarks'] ?? "";
        aiScore = data['ai_score'] ?? 0;
        aiSuggestions = data['ai_suggestions'] ?? "";
        strengths = data['strengths'] ?? "";
        missingSkills = data['missing_skills'] ?? "";
      }
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> saveScore() async {
    final score = int.tryParse(scoreController.text.trim());
    if (score == null || score < 0 || score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid score")),
      );
      return;
    }

    setState(() => saving = true);
    try {
      await Supabase.instance.client.from('resume_scores').update({
        'score': score,
        'remarks': remarksController.text.trim(),
        'admin_override': true,
      }).eq('username', widget.username);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
    if (mounted) setState(() => saving = false);
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
    final previewScore = int.tryParse(scoreController.text) ?? 0;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumScreen(
      title: "Hybrid Resume Reviews",
      subtitle: "Groq + Manual ATS",
      icon: Icons.bar_chart,
      scrollable: true,
      child: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                PremiumCard(
                  child: Row(
                    children: [
                      GlassIcon(icon: Icons.person),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(widget.username,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _scoreCard("Manual / Final Score", previewScore)),
                    const SizedBox(width: 14),
                    Expanded(child: _scoreCard("Groq AI Score", aiScore)),
                  ],
                ),
                const SizedBox(height: 20),
                _infoCard("Missing Skills", missingSkills, Icons.warning, Colors.orange),
                const SizedBox(height: 16),
                _infoCard("AI Strengths", strengths, Icons.star, Colors.green),
                const SizedBox(height: 16),
                _infoCard("Groq Suggestions", aiSuggestions, Icons.auto_awesome, Colors.purple),
                const SizedBox(height: 20),

                // 👇 Full lavender/purple card for Admin Final Review
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3B2A5E).withValues(alpha: 0.4)
                        : const Color(0xFFEDE7F6).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin Final Review",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _inputField(scoreController, "Enter final manual score", Icons.score,
                            keyboard: TextInputType.number),
                        const SizedBox(height: 16),
                        _inputField(remarksController, "Admin remarks...", Icons.comment, maxLines: 5),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: saving ? null : saveScore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Save Score"),
                ),
              ],
            ),
    );
  }

  Widget _scoreCard(String label, int score) {
    return PremiumCard(
      child: Column(
        children: [
          Text("$score%",
              style: TextStyle(
                  color: scoreColor(score),
                  fontSize: 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String text, IconData icon, Color color) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        Text(text.isEmpty ? "-" : text,
            style: TextStyle(color: secondaryColor, height: 1.5)),
      ]),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondaryColor),
        prefixIcon: Icon(icon, color: secondaryColor),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
