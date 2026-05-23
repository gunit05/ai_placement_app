import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';
import 'admin_resume_score_screen.dart';
import 'pdf_viewer_screen.dart';

class AdminResumeListScreen extends StatefulWidget {
  const AdminResumeListScreen({super.key});

  @override
  State<AdminResumeListScreen> createState() =>
      _AdminResumeListScreenState();
}

class _AdminResumeListScreenState
    extends State<AdminResumeListScreen> {
  List<Map<String, dynamic>> allResumes = [];
  List<Map<String, dynamic>> filteredResumes = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    try {
      final data = await Supabase.instance.client
          .from('resume_uploads')
          .select()
          .order('created_at', ascending: false);

      allResumes =
          List<Map<String, dynamic>>.from(data);

      filteredResumes = allResumes;
    } catch (_) {}

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void applySearch(String value) {
    setState(() {
      filteredResumes =
          allResumes.where((r) {
        final name =
            (r['username'] ?? "")
                .toString()
                .toLowerCase();

        return name.contains(
          value.toLowerCase(),
        );
      }).toList();
    });
  }

  Widget chip(
    String label,
    int score,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Text(
        "$label: $score%",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "Hybrid Resume Reviews",
      subtitle: "Groq + Manual ATS",
      icon: Icons.analytics,
      scrollable: false,
      child: Column(
        children: [
          PremiumCard(
            child: TextField(
              onChanged: applySearch,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: "Search username...",
                hintStyle: TextStyle(
                  color: Colors.white54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        filteredResumes.length,
                    itemBuilder: (_, i) {
                      final r =
                          filteredResumes[i];

                      final username =
                          r['username'];

                      final scoreData =
                          r['resume_scores'];

                      final manual =
                          scoreData?['score'] ??
                              0;

                      final ai =
                          scoreData?['ai_score'] ??
                              0;

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                                bottom: 16),
                        child: PremiumCard(
                          child: Column(
                            children: [
                              Text(
                                username,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: chip(
                                      "Manual",
                                      manual,
                                      Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 10),
                                  Expanded(
                                    child: chip(
                                      "Groq AI",
                                      ai,
                                      Colors.green,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        PremiumButton(
                                      text:
                                          "View PDF",
                                      icon: Icons
                                          .visibility,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    PdfViewerScreen(
                                              url: r[
                                                  'file_url'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 12),

                                  Expanded(
                                    child:
                                        PremiumButton(
                                      text:
                                          "Review",
                                      icon: Icons
                                          .analytics,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    AdminResumeScoreScreen(
                                              username:
                                                  username,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}