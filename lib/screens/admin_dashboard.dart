import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/premium_ui.dart';

import 'login_screen.dart';
import 'admin_resume_list_screen.dart';
import 'admin_add_job_screen.dart';
import 'admin_applications_screen.dart';
import 'admin_interview_list_screen.dart';
import 'admin_coding_list_screen.dart';
import 'shortlist_dashboard.dart';
import 'admin_feedback_screen.dart';
import 'admin_logs_analytics.dart';

class AdminDashboard
    extends StatelessWidget {

  final String username;

  const AdminDashboard({
    super.key,
    required this.username,
  });

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
            child:
                SingleChildScrollView(

              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.all(
                      22),

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

                      Container(
                        padding:
                            const EdgeInsets
                                .all(14),

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                  0xff7B2FF7),

                              Color(
                                  0xff4A00E0),
                            ],
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),

                        child:
                            const Icon(
                          Icons
                              .admin_panel_settings,

                          color:
                              Colors.white,

                          size: 32,
                        ),
                      ),

                      const SizedBox(
                          width: 16),

                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Text(
                              "Admin Panel",

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

                            const SizedBox(
                                height:
                                    4),

                            Text(
                              username,

                              maxLines:
                                  1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,

                                fontSize:
                                    15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {

                          await Supabase
                              .instance
                              .client
                              .auth
                              .signOut();

                          if (!context
                              .mounted) {
                            return;
                          }

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      const LoginScreen(),
                            ),
                          );
                        },

                        child:
                            Container(
                          padding:
                              const EdgeInsets
                                  .all(
                                      14),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.red,

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        18),
                          ),

                          child:
                              const Icon(
                            Icons.logout,

                            color:
                                Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 35),

                  // =========================
                  // HERO CARD
                  // =========================

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(28),

                    decoration:
                        BoxDecoration(

                      borderRadius:
                          BorderRadius
                              .circular(
                                  35),

                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,

                        end:
                            Alignment.bottomRight,

                        colors: [
                          Color(
                              0xff7B2FF7),

                          Color(
                              0xff4A00E0),
                        ],
                      ),

                      boxShadow: [

                        BoxShadow(
                          color: Colors
                              .deepPurple
                              .withOpacity(
                                  0.45),

                          blurRadius:
                              35,

                          spreadRadius:
                              5,

                          offset:
                              const Offset(
                                  0,
                                  15),
                        ),
                      ],
                    ),

                    child:
                        Column(
                      children: [

                        const Icon(
                          Icons
                              .dashboard_customize,

                          color:
                              Colors.white,

                          size: 90,
                        ),

                        const SizedBox(
                            height:
                                20),

                        const Text(
                          "AI Placement Admin",

                          textAlign:
                              TextAlign.center,

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

                        const SizedBox(
                            height:
                                10),

                        const Text(
                          "Manage jobs, resumes, interviews & analytics",

                          textAlign:
                              TextAlign.center,

                          style:
                              TextStyle(
                            color:
                                Colors.white70,

                            fontSize:
                                15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 35),

                  const Text(
                    "Admin Controls",

                    style:
                        TextStyle(
                      color:
                          Colors.white,

                      fontSize:
                          28,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  // =========================
                  // GRID
                  // =========================

                  GridView.count(
                    shrinkWrap:
                        true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    crossAxisCount:
                        2,

                    crossAxisSpacing:
                        18,

                    mainAxisSpacing:
                        18,

                    childAspectRatio:
                        0.92,

                    children: [

                      _tile(
                        context,
                        "Resumes",
                        Icons.picture_as_pdf,

                        Colors.blue,

                        () => _go(
                          context,

                          const AdminResumeListScreen(),
                        ),
                      ),

                      _tile(
                        context,
                        "Applications",
                        Icons.assignment,

                        Colors.orange,

                        () => _go(
                          context,

                          const AdminApplicationsScreen(),
                        ),
                      ),

                      _tile(
                        context,
                        "Interviews",
                        Icons.mic,

                        Colors.purple,

                        () => _go(
                          context,

                          const AdminInterviewListScreen(),
                        ),
                      ),

                      _tile(
                        context,
                        "Coding",
                        Icons.code,

                        Colors.green,

                        () => _go(
                          context,

                          const AdminCodingListScreen(),
                        ),
                      ),

                      _tile(
                        context,
                        "Jobs",
                        Icons.work,

                        Colors.cyan,

                        () => _go(
                          context,

                          const AdminAddJobScreen(),
                        ),
                      ),

                      _tile(
                        context,
                        "Shortlist",
                        Icons.star,

                        Colors.amber,

                        () => _go(
                          context,

                          const ShortlistDashboard(),
                        ),
                      ),

                      _tile(
                        context,
                        "Feedback",
                        Icons.feedback,

                        Colors.pink,

                        () => _go(
                          context,

                          const AdminFeedbackScreen(),
                        ),
                      ),

                      _tile(
                        context,
                        "Analytics",
                        Icons.bar_chart,

                        Colors.teal,

                        () => _go(
                          context,

                          const AdminLogsAnalytics(),
                        ),
                      ),

                      _tile(
                        context,
                        "Logout",
                        Icons.logout,

                        Colors.red,

                        () async {

                          await Supabase
                              .instance
                              .client
                              .auth
                              .signOut();

                          if (!context
                              .mounted) {
                            return;
                          }

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      const LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TILE
  // =========================

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {

    return GestureDetector(
      onTap: onTap,

      child:
          AnimatedContainer(
        duration:
            const Duration(
                milliseconds: 300),

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
                  30),

          boxShadow: [

            BoxShadow(
              color:
                  color.withOpacity(
                      0.30),

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
              MainAxisAlignment
                  .center,

          children: [

            Container(
              padding:
                  const EdgeInsets
                      .all(16),

              decoration:
                  BoxDecoration(
                color: color,

                borderRadius:
                    BorderRadius
                        .circular(
                            20),
              ),

              child: Icon(
                icon,

                size: 34,

                color:
                    Colors.white,
              ),
            ),

            const SizedBox(
                height: 18),

            Text(
              title,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // NAVIGATION
  // =========================

  void _go(
    BuildContext context,
    Widget page,
  ) {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }
}