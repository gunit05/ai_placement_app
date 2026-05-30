import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';
import '../theme/theme_controller.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> applications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> loadApplications() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('applications')
          .select('id, status, shortlisted, username, jobs(company, role, location)')
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        applications = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> updateStatus(String id, String username, String status) async {
    await supabase.from('applications').update({
      'status': status,
      'shortlisted': status == 'Shortlisted'
    }).eq('id', id);

    await supabase.from('notifications').insert({
      'username': username,
      'title': 'Application Update',
      'message': status == 'Shortlisted'
          ? '🎉 You are shortlisted!'
          : '❌ Application rejected',
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Text("Updated → $status"),
      ),
    );
    loadApplications();
  }

  Color statusColor(String status) {
    if (status == 'Shortlisted') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : applications.isEmpty
                ? Center(
                    child: Text(
                      "No Applications Yet",
                      style: TextStyle(color: secondaryColor, fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadApplications,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _iconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                              const Spacer(),
                              Text(
                                "Applications",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Spacer(),
                              _iconButton(Icons.refresh, loadApplications),
                            ],
                          ),
                          const SizedBox(height: 30),
                          ...applications.map((a) {
                            final job = a['jobs'] ?? {};
                            final status = a['status'] ?? 'Applied';
                            final color = statusColor(status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: color,
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a['username'] ?? "Unknown",
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              status,
                                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _info(Icons.business, "Company", job['company'], textColor, secondaryColor),
                                  _info(Icons.work, "Role", job['role'], textColor, secondaryColor),
                                  _info(Icons.location_on, "Location", job['location'], textColor, secondaryColor),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _statusButton(
                                          "Select",
                                          status == 'Shortlisted' ? null : () => updateStatus(a['id'], a['username'], 'Shortlisted'),
                                          status == 'Shortlisted' ? Colors.grey : Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _statusButton(
                                          "Reject",
                                          status == 'Rejected' ? null : () => updateStatus(a['id'], a['username'], 'Rejected'),
                                          status == 'Rejected' ? Colors.grey : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  Widget _statusButton(String text, VoidCallback? onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String? value, Color textColor, Color? secondaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: secondaryColor),
          const SizedBox(width: 8),
          Text("$label: ", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "N/A", style: TextStyle(color: secondaryColor))),
        ],
      ),
    );
  }
}
