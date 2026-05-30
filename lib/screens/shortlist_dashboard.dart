import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class ShortlistDashboard extends StatefulWidget {
  const ShortlistDashboard({super.key});

  @override
  State<ShortlistDashboard> createState() => _ShortlistDashboardState();
}

class _ShortlistDashboardState extends State<ShortlistDashboard> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> applications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (mounted) {
      setState(() => loading = true);
    }

    try {
      final res = await supabase.from('applications').select().order(
            'created_at',
            ascending: false,
          );

      applications = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint(
        "SHORTLIST ERROR: $e",
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> toggleShortlist(
    Map<String, dynamic> item,
  ) async {
    final newValue = !(item['shortlisted'] ?? false);

    try {
      await supabase.from('applications').update({
        'shortlisted': newValue,
      }).eq(
        'id',
        item['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue ? "Shortlisted ✅" : "Removed ❌",
          ),
        ),
      );

      fetchData();
    } catch (e) {
      debugPrint(
        "UPDATE ERROR: $e",
      );
    }
  }

  Color statusColor(
    bool shortlisted,
  ) {
    return shortlisted ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = Theme.of(context).colorScheme.onSurface;

    final secondaryTextColor = textColor.withOpacity(0.7);

    final statusBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    return PremiumScreen(
      title: "Shortlist Dashboard",
      subtitle: "Manage candidate applications",
      icon: Icons.how_to_reg,
      scrollable: false,
      actions: [
        IconButton(
          onPressed: fetchData,
          icon: Icon(
            Icons.refresh,
            color: textColor,
          ),
        ),
      ],
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : applications.isEmpty
              ? Center(
                  child: Text(
                    "No applications found",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: ListView.builder(
                    itemCount: applications.length,
                    itemBuilder: (_, i) {
                      final item = applications[i];

                      final isShortlisted = item['shortlisted'] ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: PremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      14,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.purple,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['username'] ?? "Unknown",
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          "Job ID: ${item['job_id'] ?? 'N/A'}",
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              Container(
                                padding: const EdgeInsets.all(
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isShortlisted
                                          ? "Shortlisted"
                                          : "Not Shortlisted",
                                      style: TextStyle(
                                        color: statusColor(
                                          isShortlisted,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Switch(
                                      value: isShortlisted,
                                      activeColor: Colors.white,
                                      activeTrackColor: Colors.green,
                                      inactiveThumbColor:
                                          isDark ? Colors.white : Colors.black,
                                      inactiveTrackColor: isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                      onChanged: (_) => toggleShortlist(
                                        item,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
