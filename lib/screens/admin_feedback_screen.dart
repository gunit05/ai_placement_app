import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  late Future<List> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchAll();
  }

  Future<List> fetchAll() async {
    try {
      return await Supabase.instance.client
          .from('feedback')
          .select()
          .order('time', ascending: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    setState(() => futureData = fetchAll());
  }

  Future<void> updateStatus(String id, String status) async {
    await Supabase.instance.client.from('feedback').update({'status': status}).eq('id', id);
    await refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Marked as $status")));
  }

  Future<void> replyDialog(String id) async {
    final controller = TextEditingController();
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;
    final dialogBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Reply to User",
                  style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Enter reply...",
                  hintStyle: TextStyle(color: secondaryColor),
                  filled: true,
                  fillColor: dialogBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PremiumButton(
                text: "Send Reply",
                icon: Icons.send,
                onTap: () async {
                  if (controller.text.trim().isEmpty) return;
                  await Supabase.instance.client.from('feedback').update({
                    'reply': controller.text.trim(),
                    'status': 'seen',
                  }).eq('id', id);
                  if (!mounted) return;
                  Navigator.pop(context);
                  await refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reply sent ✅")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'seen':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;
    final cardBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    return PremiumScreen(
      title: "Admin Feedback",
      subtitle: "Manage user messages & replies",
      icon: Icons.feedback,
      scrollable: false,
      actions: [
        IconButton(onPressed: refresh, icon: Icon(Icons.refresh, color: textColor)),
      ],
      child: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder(
          future: futureData,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            final data = snapshot.data as List? ?? [];
            if (data.isEmpty) {
              return Center(
                child: Text("No feedback available", style: TextStyle(color: secondaryColor, fontSize: 16)),
              );
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final f = data[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(f['message'] ?? "",
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            PopupMenuButton(
                              color: Theme.of(context).colorScheme.surface,
                              onSelected: (v) {
                                if (v == 'reply') replyDialog(f['id']);
                                if (v == 'seen') updateStatus(f['id'], 'seen');
                                if (v == 'resolved') updateStatus(f['id'], 'resolved');
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'reply', child: Text("Reply")),
                                PopupMenuItem(value: 'seen', child: Text("Mark Seen")),
                                PopupMenuItem(value: 'resolved', child: Text("Resolve")),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("User: ${f['user']}", style: TextStyle(color: secondaryColor)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text("Status: ", style: TextStyle(color: secondaryColor)),
                            Text(f['status'] ?? "new",
                                style: TextStyle(color: statusColor(f['status'] ?? "new"), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (f['reply'] != null && f['reply'].toString().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                            child: Text("Reply: ${f['reply']}", style: TextStyle(color: textColor)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
