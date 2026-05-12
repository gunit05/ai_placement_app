import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/premium_ui.dart';

class AdminAnalyticsScreen
    extends StatefulWidget {

  const AdminAnalyticsScreen({
    super.key,
  });

  @override
  State<AdminAnalyticsScreen>
      createState() =>
          _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState
    extends State<AdminAnalyticsScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  int totalJobs = 0;
  int totalUsers = 0;
  int totalApplications = 0;
  int selectedCount = 0;

  int totalInterviews = 0;

  double avgScore = 0;
  double avgConfidence = 0;

  Map<String, int> companyStats = {};

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  // =========================
  // LOAD STATS
  // =========================

  Future<void> loadStats() async {

    setState(() => loading = true);

    try {

      final results =
          await Future.wait([

        supabase
            .from('jobs')
            .select(),

        supabase
            .from('users')
            .select(),

        supabase
            .from('applications')
            .select(),

        supabase
            .from('interview_results')
            .select(),
      ]);

      final jobs =
          List<Map<String, dynamic>>
              .from(results[0]);

      final users =
          List.from(results[1]);

      final applications =
          List<Map<String, dynamic>>
              .from(results[2]);

      final interviews =
          List<Map<String, dynamic>>
              .from(results[3]);

      companyStats.clear();

      totalJobs = jobs.length;

      totalUsers = users.length;

      totalApplications =
          applications.length;

      selectedCount =
          applications
              .where(
                (a) =>
                    a['status'] ==
                    'Selected',
              )
              .length;

      // =========================
      // COMPANY STATS
      // =========================

      for (final a
          in applications) {

        final job =
            jobs.where(
          (j) =>
              j['id'] ==
              a['job_id'],
        );

        if (job.isEmpty) continue;

        final company =
            job.first['company'] ??
                "Unknown";

        companyStats[company] =
            (companyStats[
                        company] ??
                    0) +
                1;
      }

      totalInterviews =
          interviews.length;

      double scoreSum = 0;
      double confidenceSum = 0;

      for (final i
          in interviews) {

        scoreSum +=
            (i['score'] ?? 0);

        confidenceSum +=
            (i['confidence'] ??
                0);
      }

      avgScore =
          totalInterviews == 0
              ? 0
              : scoreSum /
                  totalInterviews;

      avgConfidence =
          totalInterviews == 0
              ? 0
              : confidenceSum /
                  totalInterviews;

    } catch (e) {

      debugPrint(
        "ANALYTICS ERROR: $e",
      );
    }

    if (mounted) {
      setState(
          () => loading = false);
    }
  }

  double placementRate() {

    if (totalApplications == 0) {
      return 0;
    }

    return (selectedCount /
            totalApplications) *
        100;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          AppTheme.darkBg,

      body: Stack(
        children: [

          // =========================
          // BACKGROUND GLOW
          // =========================

          Positioned(
            top: -120,
            left: -80,

            child: Container(
              width: 260,
              height: 260,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color: Colors
                    .deepPurple
                    .withOpacity(0.25),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            right: -100,

            child: Container(
              width: 300,
              height: 300,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color: Colors
                    .purpleAccent
                    .withOpacity(0.18),
              ),
            ),
          ),

          SafeArea(
            child: loading

                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )

                : RefreshIndicator(
                    onRefresh:
                        loadStats,

                    child:
                        SingleChildScrollView(

                      physics:
                          const BouncingScrollPhysics(),

                      padding:
                          const EdgeInsets
                              .all(22),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          // =========================
                          // TOP BAR
                          // =========================

                          Row(
                            children: [

                              GestureDetector(
                                onTap: () =>
                                    Navigator.pop(
                                        context),

                                child:
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .all(
                                              12),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .white10,

                                    borderRadius:
                                        BorderRadius.circular(
                                            18),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .arrow_back_ios_new,

                                    color: Colors
                                        .white,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              const Text(
                                "Analytics",

                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,

                                  fontSize:
                                      30,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const Spacer(),

                              GestureDetector(
                                onTap:
                                    loadStats,

                                child:
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .all(
                                              12),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .white10,

                                    borderRadius:
                                        BorderRadius.circular(
                                            18),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .refresh,

                                    color: Colors
                                        .white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 30),

                          // =========================
                          // SUMMARY
                          // =========================

                          const Text(
                            "Overview",

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontSize:
                                  26,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          GridView.count(
                            crossAxisCount:
                                2,

                            shrinkWrap:
                                true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            crossAxisSpacing:
                                16,

                            mainAxisSpacing:
                                16,

                            childAspectRatio:
                                1.05,

                            children: [

                              _card(
                                "Jobs",
                                totalJobs,
                                Icons.work,
                                Colors.blue,
                              ),

                              _card(
                                "Users",
                                totalUsers,
                                Icons.people,
                                Colors.green,
                              ),

                              _card(
                                "Applications",
                                totalApplications,
                                Icons.assignment,
                                Colors.orange,
                              ),

                              _card(
                                "Selected",
                                selectedCount,
                                Icons.check_circle,
                                Colors.purple,
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 30),

                          // =========================
                          // INTERVIEW
                          // =========================

                          const Text(
                            "Interview Stats",

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontSize:
                                  26,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          GridView.count(
                            crossAxisCount:
                                2,

                            shrinkWrap:
                                true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            crossAxisSpacing:
                                16,

                            mainAxisSpacing:
                                16,

                            childAspectRatio:
                                1.05,

                            children: [

                              _card(
                                "Interviews",
                                totalInterviews,
                                Icons.mic,
                                Colors.cyan,
                              ),

                              _card(
                                "Avg Score",
                                avgScore.toStringAsFixed(
                                    1),

                                Icons.emoji_events,

                                Colors.amber,
                              ),

                              _card(
                                "Confidence",

                                avgConfidence
                                    .toStringAsFixed(
                                        1),

                                Icons.psychology,

                                Colors.pink,
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 30),

                          // =========================
                          // PLACEMENT RATE
                          // =========================

                          Container(
                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .all(
                                        22),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white10,

                              borderRadius:
                                  BorderRadius.circular(
                                      30),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const Text(
                                  "Placement Rate",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,

                                    fontSize:
                                        24,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        20),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),

                                  child:
                                      LinearProgressIndicator(
                                    minHeight:
                                        14,

                                    value:
                                        placementRate() /
                                            100,

                                    backgroundColor:
                                        Colors.white12,

                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                      AppTheme
                                          .primary,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        12),

                                Text(
                                  "${placementRate().toStringAsFixed(1)}% Placement Success",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white70,

                                    fontSize:
                                        16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 30),

                          // =========================
                          // COMPANY STATS
                          // =========================

                          const Text(
                            "Company Stats",

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontSize:
                                  26,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          ...companyStats
                              .entries
                              .map(

                            (e) =>
                                Padding(
                              padding:
                                  const EdgeInsets.only(
                                      bottom:
                                          14),

                              child:
                                  Container(
                                padding:
                                    const EdgeInsets.all(
                                        18),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white10,

                                  borderRadius:
                                      BorderRadius.circular(
                                          24),
                                ),

                                child:
                                    Row(
                                  children: [

                                    Container(
                                      padding:
                                          const EdgeInsets.all(
                                              14),

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.deepPurple,

                                        borderRadius:
                                            BorderRadius.circular(
                                                18),
                                      ),

                                      child:
                                          const Icon(
                                        Icons.business,

                                        color:
                                            Colors.white,
                                      ),
                                    ),

                                    const SizedBox(
                                        width:
                                            16),

                                    Expanded(
                                      child:
                                          Text(
                                        e.key,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,

                                          fontSize:
                                              18,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      "${e.value}",

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white70,

                                        fontSize:
                                            18,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CARD
  // =========================

  Widget _card(
    String title,
    dynamic value,
    IconData icon,
    Color color,
  ) {

    return Container(
      padding:
          const EdgeInsets.all(
              18),

      decoration:
          BoxDecoration(

        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,

          colors: [
            Color(0xff111C44),
            Color(0xff09122F),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
                28),

        boxShadow: [

          BoxShadow(
            color: color
                .withOpacity(0.35),

            blurRadius: 25,

            spreadRadius: 1,

            offset:
                const Offset(
                    0, 12),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Container(
            padding:
                const EdgeInsets
                    .all(14),

            decoration:
                BoxDecoration(
              color: color,

              borderRadius:
                  BorderRadius
                      .circular(
                          18),
            ),

            child: Icon(
              icon,
              color:
                  Colors.white,
            ),
          ),

          const SizedBox(
              height: 16),

          Text(
            "$value",

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 6),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Colors.white70,

              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}