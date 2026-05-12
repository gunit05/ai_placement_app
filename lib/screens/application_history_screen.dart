import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationHistoryScreen extends StatefulWidget {
  final String username;

  const ApplicationHistoryScreen({
    super.key,
    required this.username,
  });

  @override
  State<ApplicationHistoryScreen> createState() =>
      _ApplicationHistoryScreenState();
}

class _ApplicationHistoryScreenState
    extends State<ApplicationHistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> applications = [];

  final supabase = Supabase.instance.client;

  final List<List<Color>> gradients = [
    [Color(0xff7B2FF7), Color(0xffE940FF)],
    [Color(0xff00C9FF), Color(0xff92FE9D)],
    [Color(0xffFF6A00), Color(0xffEE0979)],
    [Color(0xff8E2DE2), Color(0xff4A00E0)],
    [Color(0xff11998E), Color(0xff38EF7D)],
  ];

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      final data = await supabase
          .from('applications')
          .select('id, status, job_id, created_at')
          .eq('username', widget.username)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> result = [];

      for (final app in data) {
        final job = await supabase
            .from('jobs')
            .select('company, role, location')
            .eq('id', app['job_id'])
            .single();

        result.add({
          'status': app['status'] ?? 'Applied',
          'company': job['company'],
          'role': job['role'],
          'location': job['location'],
          'date': app['created_at'],
        });
      }

      if (!mounted) return;

      setState(() {
        applications = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
    }
  }

  Color statusColor(String status) {
    if (status == 'Selected') return Colors.greenAccent;
    if (status == 'Rejected') return Colors.redAccent;
    return Colors.orangeAccent;
  }

  IconData statusIcon(String status) {
    if (status == 'Selected') return Icons.check_circle;
    if (status == 'Rejected') return Icons.cancel;
    return Icons.hourglass_bottom;
  }

  Widget infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Application History 📂",
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
          : applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff7B2FF7),
                              Color(0xffE940FF),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.folder_open,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No Applications Yet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics:
                      const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  itemBuilder: (context, i) {
                    final a = applications[i];
                    final gradient =
                        gradients[i % gradients.length];
                    final color = statusColor(a['status']);

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
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                child: const Icon(
                                  Icons.business_center,
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
                                      a['company'],
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      a['role'],
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          infoChip(
                            Icons.location_on,
                            a['location'] ?? 'N/A',
                          ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusIcon(
                                          a['status']),
                                      color: color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      a['status'],
                                      style:
                                          TextStyle(
                                        color: color,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                a['date']
                                    .toString()
                                    .substring(0, 10),
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}