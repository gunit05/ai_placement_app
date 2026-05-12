import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/premium_ui.dart';

class AdminApplicationsScreen
    extends StatefulWidget {

  const AdminApplicationsScreen({
    super.key,
  });

  @override
  State<AdminApplicationsScreen>
      createState() =>
          _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState
    extends State<AdminApplicationsScreen> {

  final supabase =
      Supabase.instance.client;

  List<Map<String, dynamic>>
      applications = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  // =========================
  // LOAD APPLICATIONS
  // =========================

  Future<void> loadApplications() async {

    setState(() => loading = true);

    try {

      final data =
          await supabase
              .from(
                  'applications')
              .select(
                  'id, status, shortlisted, username, jobs(company, role, location)')
              .order(
                'created_at',
                ascending: false,
              );

      if (!mounted) return;

      setState(() {

        applications =
            List<Map<String,
                dynamic>>.from(
          data,
        );

        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(
          () => loading = false);
    }
  }

  // =========================
  // UPDATE STATUS
  // =========================

  Future<void> updateStatus(
    String id,
    String username,
    String status,
  ) async {

    await supabase
        .from('applications')
        .update({

      'status': status,

      'shortlisted':
          status ==
              'Shortlisted'
    }).eq('id', id);

    await supabase
        .from('notifications')
        .insert({

      'username': username,

      'title':
          'Application Update',

      'message':
          status ==
                  'Shortlisted'

              ? '🎉 You are shortlisted!'

              : '❌ Application rejected',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        backgroundColor:
            AppTheme.primary,

        content: Text(
          "Updated → $status",
        ),
      ),
    );

    loadApplications();
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color statusColor(
      String status) {

    if (status ==
        'Shortlisted') {
      return Colors.green;
    }

    if (status ==
        'Rejected') {
      return Colors.red;
    }

    return Colors.orange;
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

                : applications
                        .isEmpty

                    ? const Center(
                        child: Text(
                          "No Applications Yet",

                          style:
                              TextStyle(
                            color: Colors
                                .white70,

                            fontSize:
                                18,
                          ),
                        ),
                      )

                    : RefreshIndicator(
                        onRefresh:
                            loadApplications,

                        child:
                            SingleChildScrollView(

                          physics:
                              const BouncingScrollPhysics(),

                          padding:
                              const EdgeInsets
                                  .all(
                                      22),

                          child:
                              Column(
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

                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  const Text(
                                    "Applications",

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

                                  const Spacer(),

                                  GestureDetector(
                                    onTap:
                                        loadApplications,

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

                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height:
                                      30),

                              // =========================
                              // LIST
                              // =========================

                              ...applications
                                  .map(

                                (a) {

                                  final job =
                                      a['jobs'] ??
                                          {};

                                  final status =
                                      a['status'] ??
                                          'Applied';

                                  final color =
                                      statusColor(
                                          status);

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                            bottom:
                                                18),

                                    child:
                                        Container(

                                      padding:
                                          const EdgeInsets.all(
                                              20),

                                      decoration:
                                          BoxDecoration(

                                        gradient:
                                            const LinearGradient(
                                          begin:
                                              Alignment.topLeft,

                                          end:
                                              Alignment.bottomRight,

                                          colors: [
                                            Color(
                                                0xff111C44),

                                            Color(
                                                0xff09122F),
                                          ],
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(
                                                30),

                                        boxShadow: [

                                          BoxShadow(
                                            color: color.withOpacity(
                                                0.22),

                                            blurRadius:
                                                22,

                                            spreadRadius:
                                                1,

                                            offset:
                                                const Offset(
                                                    0,
                                                    12),
                                          ),
                                        ],
                                      ),

                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [

                                          // =========================
                                          // USER
                                          // =========================

                                          Row(
                                            children: [

                                              Container(
                                                padding:
                                                    const EdgeInsets.all(
                                                        14),

                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      color,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18),
                                                ),

                                                child:
                                                    const Icon(
                                                  Icons.person,

                                                  color:
                                                      Colors.white,
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
                                                      a['username'] ??
                                                          "Unknown",

                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.white,

                                                        fontSize:
                                                            20,

                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                        height:
                                                            4),

                                                    Text(
                                                      status,

                                                      style:
                                                          TextStyle(
                                                        color:
                                                            color,

                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                              height:
                                                  20),

                                          _info(
                                            Icons.business,
                                            "Company",

                                            job['company'],
                                          ),

                                          _info(
                                            Icons.work,
                                            "Role",

                                            job['role'],
                                          ),

                                          _info(
                                            Icons.location_on,
                                            "Location",

                                            job['location'],
                                          ),

                                          const SizedBox(
                                              height:
                                                  20),

                                          Row(
                                            children: [

                                              Expanded(
                                                child:
                                                    GestureDetector(

                                                  onTap:
                                                      status ==
                                                              'Shortlisted'

                                                          ? null

                                                          : () =>
                                                              updateStatus(

                                                            a['id'],

                                                            a['username'],

                                                            'Shortlisted',
                                                          ),

                                                  child:
                                                      Container(

                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      vertical:
                                                          16,
                                                    ),

                                                    decoration:
                                                        BoxDecoration(

                                                      color:
                                                          status ==
                                                                  'Shortlisted'

                                                              ? Colors.grey

                                                              : Colors.green,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),

                                                    child:
                                                        const Center(
                                                      child:
                                                          Text(

                                                        "Select",

                                                        style:
                                                            TextStyle(
                                                          color:
                                                              Colors.white,

                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(
                                                  width:
                                                      14),

                                              Expanded(
                                                child:
                                                    GestureDetector(

                                                  onTap:
                                                      status ==
                                                              'Rejected'

                                                          ? null

                                                          : () =>
                                                              updateStatus(

                                                            a['id'],

                                                            a['username'],

                                                            'Rejected',
                                                          ),

                                                  child:
                                                      Container(

                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      vertical:
                                                          16,
                                                    ),

                                                    decoration:
                                                        BoxDecoration(

                                                      color:
                                                          status ==
                                                                  'Rejected'

                                                              ? Colors.grey

                                                              : Colors.red,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),

                                                    child:
                                                        const Center(
                                                      child:
                                                          Text(

                                                        "Reject",

                                                        style:
                                                            TextStyle(
                                                          color:
                                                              Colors.white,

                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                  height:
                                      40),
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
  // INFO TILE
  // =========================

  Widget _info(
    IconData icon,
    String label,
    String? value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 12),

      child: Row(
        children: [

          Icon(
            icon,

            size: 18,

            color:
                Colors.white70,
          ),

          const SizedBox(width: 10),

          Text(
            "$label: ",

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              value ?? "N/A",

              style:
                  const TextStyle(
                color:
                    Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}