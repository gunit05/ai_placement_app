import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class JobsScreen extends StatefulWidget {
  final String username;

  const JobsScreen({
    super.key,
    required this.username,
  });

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  List jobs = [];
  Set appliedJobIds = {};
  bool loading = true;

  final List<List<Color>> gradients = [
    [const Color(0xffFF6A00), const Color(0xffEE0979)],
    [const Color(0xff00C9FF), const Color(0xff92FE9D)],
    [const Color(0xff8E2DE2), const Color(0xff4A00E0)],
    [const Color(0xffFC466B), const Color(0xff3F5EFB)],
    [const Color(0xff11998E), const Color(0xff38EF7D)],
  ];

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    setState(() => loading = true);

    await Future.wait([
      fetchJobs(),
      fetchAppliedJobs(),
    ]);

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> fetchJobs() async {
    final data = await Supabase.instance.client
        .from('jobs')
        .select()
        .order('created_at', ascending: false);

    jobs = data;
  }

  Future<void> fetchAppliedJobs() async {
    final data = await Supabase.instance.client
        .from('applications')
        .select('job_id')
        .eq('username', widget.username);

    appliedJobIds = data.map((e) => e['job_id']).toSet();
  }

  Future<void> applyJob(String jobId) async {
    if (appliedJobIds.contains(jobId)) {
      _show("Already applied");
      return;
    }

    await Supabase.instance.client
        .from('applications')
        .insert({
      'job_id': jobId,
      'username': widget.username,
      'status': 'Applied',
    });

    if (!mounted) return;

    setState(() {
      appliedJobIds.add(jobId);
    });

    _show("Applied successfully");
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null || date.length < 10) return "";
    return date.substring(0, 10);
  }

  Widget infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
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

  Widget emptyState(bool isDark) {
    return Center(
      child: PremiumCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_outline,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "No Jobs Available",
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "New opportunities will appear here.",
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: glow(
              260,
              AppTheme.primary.withValues(alpha: 0.20),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(
              300,
              Colors.blue.withValues(alpha: 0.10),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pop(context),
                        child: Container(
                          padding:
                              const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
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
                              "Find Jobs",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(
                              "AI-powered opportunities",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                      : jobs.isEmpty
                          ? emptyState(isDark)
                          : RefreshIndicator(
                              onRefresh: loadAll,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.all(
                                        16),
                                itemCount: jobs.length,
                                itemBuilder:
                                    (context, i) {
                                  final job = jobs[i];
                                  final applied =
                                      appliedJobIds
                                          .contains(
                                    job['id'],
                                  );

                                  final gradient =
                                      gradients[i %
                                          gradients
                                              .length];

                                  return Container(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      bottom: 18,
                                    ),
                                    padding:
                                        const EdgeInsets
                                            .all(18),
                                    decoration:
                                        BoxDecoration(
                                      gradient:
                                          LinearGradient(
                                        begin: Alignment
                                            .topLeft,
                                        end: Alignment
                                            .bottomRight,
                                        colors:
                                            gradient,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradient
                                              .first
                                              .withValues(
                                            alpha: 0.30,
                                          ),
                                          blurRadius:
                                              20,
                                          offset:
                                              const Offset(
                                            0,
                                            10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .all(
                                                          14),
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors
                                                    .white
                                                    .withValues(
                                                  alpha:
                                                      0.20,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20),
                                              ),
                                              child:
                                                  const Icon(
                                                Icons
                                                    .business_center,
                                                color: Colors
                                                    .white,
                                                size:
                                                    28,
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    14),
                                            Expanded(
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    job['company'] ??
                                                        "Company",
                                                    style:
                                                        const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          4),
                                                  Text(
                                                    job['role'] ??
                                                        "",
                                                    style:
                                                        const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                            height:
                                                16),

                                        Wrap(
                                          spacing: 10,
                                          runSpacing:
                                              10,
                                          children: [
                                            infoChip(
                                              Icons
                                                  .location_on,
                                              job['location'] ??
                                                  "N/A",
                                            ),
                                            infoChip(
                                              Icons.work,
                                              job['job_type'] ??
                                                  "Full Time",
                                            ),
                                            if (job['salary'] !=
                                                null)
                                              infoChip(
                                                Icons
                                                    .currency_rupee,
                                                "${job['salary']}",
                                              ),
                                          ],
                                        ),

                                        const SizedBox(
                                            height:
                                                16),

                                        if (job['description'] !=
                                            null)
                                          Text(
                                            job['description'],
                                            maxLines: 3,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color: Colors
                                                  .white,
                                              height:
                                                  1.5,
                                            ),
                                          ),

                                        const SizedBox(
                                            height:
                                                12),

                                        Text(
                                          "Posted: ${formatDate(job['created_at'])}",
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white70,
                                            fontSize:
                                                12,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                18),

                                        SizedBox(
                                          width: double
                                              .infinity,
                                          height: 52,
                                          child:
                                              ElevatedButton(
                                            onPressed:
                                                applied
                                                    ? null
                                                    : () => applyJob(
                                                          job['id'],
                                                        ),
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              foregroundColor:
                                                  Colors
                                                      .black,
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18),
                                              ),
                                            ),
                                            child:
                                                Text(
                                              applied
                                                  ? "Already Applied"
                                                  : "Apply Now",
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
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

  Widget glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}