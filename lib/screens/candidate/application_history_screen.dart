import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire_hub/theme/premium_ui.dart';

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

class _ApplicationHistoryScreenState extends State<ApplicationHistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> applications = [];

  final supabase = Supabase.instance.client;

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
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  IconData statusIcon(String status) {
    if (status == 'Selected') return Icons.check_circle;
    if (status == 'Rejected') return Icons.cancel;
    return Icons.hourglass_bottom;
  }

  Widget infoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
              ),
              child: const Icon(Icons.folder_open, color: Colors.white, size: 54),
            ),
            const SizedBox(height: 20),
            Text(
              "No Applications Yet",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Applied jobs will appear here.",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
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
                      child: Icon(Icons.arrow_back_rounded,
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Application History",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            )),
                        Text("Track your job applications",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
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
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : applications.isEmpty
                      ? emptyState(isDark)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: applications.length,
                          itemBuilder: (context, i) {
                            final a = applications[i];
                            return PremiumCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppTheme.primary.withOpacity(0.15)
                                              : AppTheme.accent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.business_center,
                                            color: Color.fromARGB(255, 35, 3, 67), size: 28),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(a['company'],
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black87,
                                                  fontSize: 20,
                                                )),
                                            const SizedBox(height: 4),
                                            Text(a['role'],
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontSize: 14,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  infoChip(Icons.location_on, a['location'] ?? 'N/A', isDark),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(statusIcon(a['status']),
                                                color: AppTheme.primary, size: 18),
                                            const SizedBox(width: 6),
                                            Text(a['status'],
                                                style: TextStyle(
                                                  color: AppTheme.primary,
                                                  fontSize: 13,
                                                )),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        a['date'].toString().substring(0, 10),
                                        style: TextStyle(
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
