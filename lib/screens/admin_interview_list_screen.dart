import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/premium_ui.dart';
import '../theme/theme_controller.dart'; 
import 'video_player_screen.dart';

class AdminInterviewListScreen extends StatefulWidget {
  const AdminInterviewListScreen({super.key});

  @override
  State<AdminInterviewListScreen> createState() => _AdminInterviewListScreenState();
}

class _AdminInterviewListScreenState extends State<AdminInterviewListScreen> {
  List<Map<String, dynamic>> interviews = [];
  List<Map<String, dynamic>> filtered = [];

  bool loading = true;
  String search = "";
  String filter = "All";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (mounted) setState(() => loading = true);
    try {
      final res = await Supabase.instance.client
          .from('interview_results')
          .select()
          .order('created_at', ascending: false);

      interviews = List<Map<String, dynamic>>.from(res);
      applyFilter();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  void applyFilter() {
    filtered = interviews.where((r) {
      final name = (r['username'] ?? "").toString().toLowerCase();
      final score = (r['score'] ?? 0) as int;
      final searchMatch = name.contains(search.toLowerCase());

      bool filterMatch = true;
      if (filter == "Top") filterMatch = score >= 70;
      if (filter == "Low") filterMatch = score < 40;

      return searchMatch && filterMatch;
    }).toList();

    if (mounted) setState(() {});
  }

  bool hasVideo(dynamic url) {
    if (url == null) return false;
    final value = url.toString().trim();
    return value.isNotEmpty && value.startsWith("http");
  }

  Future<void> openVideo(String url) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(url: url)));
  }

  Future<void> downloadVideo(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> deleteInterview(Map item) async {
    await Supabase.instance.client.from('interview_results').delete().eq('id', item['id']);
    fetchData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
  }

  Color scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumScreen(
      title: "Interview Results",
      subtitle: "Admin interview review panel",
      icon: Icons.video_collection,
      scrollable: false,
      actions: [
        IconButton(
          onPressed: fetchData,
          icon: Icon(Icons.refresh, color: textColor),
        ),
      ],
      child: Column(
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: (v) {
                search = v;
                applyFilter();
              },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search username...",
                hintStyle: TextStyle(color: secondaryColor),
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              filterChip("All", textColor),
              filterChip("Top", textColor),
              filterChip("Low", textColor),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : filtered.isEmpty
                    ? Center(
                        child: Text("No interview data",
                            style: TextStyle(color: secondaryColor, fontSize: 18)),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchData,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final r = filtered[i];
                            final score = (r['score'] ?? 0) as int;
                            final videoUrl = r['video_url'];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PremiumCard(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: scoreColor(score),
                                          child: Text(score.toString(),
                                              style: const TextStyle(color: Colors.white)),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(r['username'] ?? "Unknown",
                                                  style: TextStyle(
                                                      color: textColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 17)),
                                              const SizedBox(height: 4),
                                              Text("Score: $score%",
                                                  style: TextStyle(color: secondaryColor)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (hasVideo(videoUrl))
                                      Row(
                                        children: [
                                          Expanded(
                                            child: PremiumButton(
                                              text: "Watch",
                                              icon: Icons.play_arrow,
                                              onTap: () => openVideo(videoUrl.toString()),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: PremiumButton(
                                              text: "Open",
                                              icon: Icons.download,
                                              onTap: () => downloadVideo(videoUrl.toString()),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text("Delete?"),
                                                  content: const Text("Remove interview record?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        deleteInterview(r);
                                                      },
                                                      child: const Text("Delete"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                          ),
                                        ],
                                      )
                                    else
                                      Text("No video available",
                                          style: TextStyle(color: secondaryColor)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String text, Color textColor) {
    return ChoiceChip(
      label: Text(text),
      selected: filter == text,
      selectedColor: AppTheme.primary,
      backgroundColor: Theme.of(context).cardColor,
      labelStyle: TextStyle(color: textColor),
      onSelected: (_) {
        filter = text;
        applyFilter();
      },
    );
  }
}
