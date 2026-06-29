import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire_hub/theme/premium_ui.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final supabase = Supabase.instance.client;
  bool loading = true;

  int totalJobs = 0, totalUsers = 0, totalApplications = 0, selectedCount = 0, totalInterviews = 0;
  double avgScore = 0, avgConfidence = 0;
  Map<String, int> companyStats = {};

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() => loading = true);
    try {
      final results = await Future.wait([
        supabase.from('jobs').select(),
        supabase.from('users').select(),
        supabase.from('applications').select(),
        supabase.from('interview_results').select(),
      ]);

      final jobs = List<Map<String, dynamic>>.from(results[0]);
      final users = List.from(results[1]);
      final applications = List<Map<String, dynamic>>.from(results[2]);
      final interviews = List<Map<String, dynamic>>.from(results[3]);

      companyStats.clear();
      totalJobs = jobs.length;
      totalUsers = users.length;
      totalApplications = applications.length;
      selectedCount = applications.where((a) => a['status'] == 'Selected').length;

      for (final a in applications) {
        final job = jobs.where((j) => j['id'] == a['job_id']);
        if (job.isEmpty) continue;
        final company = job.first['company'] ?? "Unknown";
        companyStats[company] = (companyStats[company] ?? 0) + 1;
      }

      totalInterviews = interviews.length;
      double scoreSum = 0, confidenceSum = 0;
      for (final i in interviews) {
        scoreSum += (i['score'] ?? 0);
        confidenceSum += (i['confidence'] ?? 0);
      }
      avgScore = totalInterviews == 0 ? 0 : scoreSum / totalInterviews;
      avgConfidence = totalInterviews == 0 ? 0 : confidenceSum / totalInterviews;
    } catch (e) {
      debugPrint("ANALYTICS ERROR: $e");
    }
    if (mounted) setState(() => loading = false);
  }

  double placementRate() => totalApplications == 0 ? 0 : (selectedCount / totalApplications) * 100;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumScreen(
      title: "Analytics",
      subtitle: "Track jobs, users & interviews",
      icon: Icons.bar_chart,
      scrollable: true,
      actions: [
        IconButton(onPressed: loadStats, icon: Icon(Icons.refresh, color: textColor)),
      ],
      child: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Overview", textColor),
                const SizedBox(height: 12),
                _grid([
                  _card("Jobs", totalJobs, Icons.work, Colors.blue),
                  _card("Users", totalUsers, Icons.people, Colors.green),
                  _card("Applications", totalApplications, Icons.assignment, Colors.orange),
                  _card("Selected", selectedCount, Icons.check_circle, Colors.purple),
                ]),
                const SizedBox(height: 20),
                _sectionTitle("Interview Stats", textColor),
                const SizedBox(height: 12),
                _grid([
                  _card("Interviews", totalInterviews, Icons.mic, Colors.cyan),
                  _card("Avg Score", avgScore.toStringAsFixed(1), Icons.emoji_events, Colors.amber),
                  _card("Confidence", avgConfidence.toStringAsFixed(1), Icons.psychology, Colors.pink),
                ]),
                const SizedBox(height: 20),
                _placementCard(textColor, secondaryColor),
                const SizedBox(height: 20),
                _sectionTitle("Company Stats", textColor),
                const SizedBox(height: 12),
                ...companyStats.entries.map((e) => _companyTile(e.key, e.value, textColor, secondaryColor)),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Text(text, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold));
  }

  Widget _grid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: children,
    );
  }

  Widget _card(String title, dynamic value, IconData icon, Color color) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumCard(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 12),
        Text("$value",
            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: secondaryColor)),
      ]),
    );
  }

  Widget _placementCard(Color textColor, Color? secondaryColor) {
    return PremiumCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Placement Rate", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: placementRate() / 100,
            backgroundColor: Colors.black26,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text("${placementRate().toStringAsFixed(1)}% Placement Success", style: TextStyle(color: secondaryColor)),
      ]),
    );
  }

  Widget _companyTile(String company, int count, Color textColor, Color? secondaryColor) {
    return PremiumCard(
      child: Row(children: [
        CircleAvatar(backgroundColor: Colors.deepPurple, child: const Icon(Icons.business, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Text(company, style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
        Text("$count", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
