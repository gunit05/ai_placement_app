import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hire_hub/theme/premium_ui.dart';

class NotificationsScreen extends StatefulWidget {
  final String username;

  const NotificationsScreen({
    super.key,
    required this.username,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('username', widget.username)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        notifications = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to load notifications"),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  IconData getIcon(String msg) {
    final text = msg.toLowerCase();
    if (text.contains("selected")) return Icons.check_circle;
    if (text.contains("rejected")) return Icons.cancel;
    if (text.contains("interview")) return Icons.mic;
    if (text.contains("job")) return Icons.work;
    return Icons.notifications_active;
  }

  String getTitle(String msg) {
    final text = msg.toLowerCase();
    if (text.contains("selected")) return "Congratulations 🎉";
    if (text.contains("rejected")) return "Application Update";
    if (text.contains("interview")) return "Interview Alert";
    if (text.contains("job")) return "Job Update";
    return "Notification";
  }

  Widget emptyState(bool isDark) {
    return Center(
      child: PremiumCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_off,
                  color: Colors.white, size: 54),
            ),
            const SizedBox(height: 20),
            Text(
              "No Notifications Yet",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Updates will appear here",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _glow(260, AppTheme.primary.withOpacity(0.22)),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(300, Colors.blue.withOpacity(0.10)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: textColor),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Notifications 🔔",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text("Your latest updates",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        )
                      : notifications.isEmpty
                          ? emptyState(isDark)
                          : RefreshIndicator(
                              onRefresh: loadNotifications,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: notifications.length,
                                itemBuilder: (context, i) {
                                  final n = notifications[i];
                                  final msg = n['message'] ?? "";

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 18),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withOpacity(0.35),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Icon(getIcon(msg),
                                              color: Colors.white, size: 28),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(getTitle(msg),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              const SizedBox(height: 8),
                                              Text(msg,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    height: 1.5,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
