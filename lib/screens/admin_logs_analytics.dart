import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';
import '../theme/theme_controller.dart'; 

class AdminLogsAnalytics extends StatefulWidget {
  const AdminLogsAnalytics({super.key});

  @override
  State<AdminLogsAnalytics> createState() => _AdminLogsAnalyticsState();
}

class _AdminLogsAnalyticsState extends State<AdminLogsAnalytics> {
  late Future<Map<String, int>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = fetchStats();
  }

  Future<Map<String, int>> fetchStats() async {
    try {
      final data = await Supabase.instance.client.from('logs').select();
      final Map<String, int> map = {};
      for (final e in data) {
        final event = (e['event'] ?? "Unknown").toString();
        map[event] = (map[event] ?? 0) + 1;
      }
      return map;
    } catch (e) {
      debugPrint("LOG ERROR: $e");
      return {};
    }
  }

  Future<void> refreshData() async {
    setState(() {
      statsFuture = fetchStats();
    });
  }

  IconData eventIcon(String event) {
    final text = event.toLowerCase();
    if (text.contains("login")) return Icons.login;
    if (text.contains("logout")) return Icons.logout;
    if (text.contains("job")) return Icons.work;
    if (text.contains("resume")) return Icons.description;
    if (text.contains("interview")) return Icons.video_call;
    if (text.contains("feedback")) return Icons.feedback;
    return Icons.analytics;
  }

  List<Color> eventGradient(String event) {
    final text = event.toLowerCase();
    if (text.contains("login")) return [Colors.green, Colors.teal];
    if (text.contains("job")) return [Colors.orange, Colors.deepOrange];
    if (text.contains("resume")) return [Colors.blue, Colors.indigo];
    if (text.contains("interview")) return [Colors.purple, Colors.pink];
    return [AppTheme.primary, AppTheme.secondary];
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumScreen(
      title: "Logs Analytics",
      subtitle: "Admin app activity dashboard",
      icon: Icons.analytics,
      scrollable: false,
      actions: [
        IconButton(
          onPressed: refreshData,
          icon: Icon(Icons.refresh, color: textColor),
        ),
      ],
      child: FutureBuilder<Map<String, int>>(
        future: statsFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final data = snapshot.data ?? {};
          if (data.isEmpty) {
            return Center(
              child: Text("No logs found", style: TextStyle(color: secondaryColor, fontSize: 18)),
            );
          }

          final entries = data.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return RefreshIndicator(
            onRefresh: refreshData,
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final item = entries[i];
                final colors = eventGradient(item.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PremiumCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors.first.withOpacity(0.35),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Icon(eventIcon(item.key), color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.key,
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Tracked system activity",
                                  style: TextStyle(color: secondaryColor)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(item.value.toString(),
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
