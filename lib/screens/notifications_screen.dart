import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  final String username;

  const NotificationsScreen({
    super.key,
    required this.username,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List notifications = [];
  bool loading = true;

  final List<List<Color>> gradients = [
    [Color(0xffFF6A00), Color(0xffEE0979)],
    [Color(0xff00C9FF), Color(0xff92FE9D)],
    [Color(0xff8E2DE2), Color(0xff4A00E0)],
    [Color(0xffFC466B), Color(0xff3F5EFB)],
    [Color(0xff11998E), Color(0xff38EF7D)],
  ];

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
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load notifications"),
        ),
      );
    }
  }

  IconData getIcon(String msg) {
    final text = msg.toLowerCase();

    if (text.contains("selected")) {
      return Icons.check_circle;
    }

    if (text.contains("rejected")) {
      return Icons.cancel;
    }

    if (text.contains("interview")) {
      return Icons.mic;
    }

    if (text.contains("job")) {
      return Icons.work;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Notifications 🔔",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff7B2FF7),
                              Color(0xffE940FF),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_off,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No Notifications Yet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Updates will appear here",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadNotifications,
                  child: ListView.builder(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, i) {
                      final n = notifications[i];
                      final msg = n['message'] ?? "";
                      final gradient =
                          gradients[i % gradients.length];

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient,
                          ),
                          borderRadius:
                              BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.first
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
                              padding:
                                  const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                              child: Icon(
                                getIcon(msg),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    getTitle(msg),
                                    style:
                                        const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    msg,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}