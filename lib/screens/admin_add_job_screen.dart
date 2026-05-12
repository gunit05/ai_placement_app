import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/premium_ui.dart';

class AdminAddJobScreen
    extends StatefulWidget {

  const AdminAddJobScreen({
    super.key,
  });

  @override
  State<AdminAddJobScreen>
      createState() =>
          _AdminAddJobScreenState();
}

class _AdminAddJobScreenState
    extends State<AdminAddJobScreen> {

  final company =
      TextEditingController();

  final role =
      TextEditingController();

  final location =
      TextEditingController();

  final type =
      TextEditingController();

  final salary =
      TextEditingController();

  final description =
      TextEditingController();

  bool loading = false;

  // =========================
  // ADD JOB
  // =========================

  Future<void> addJob() async {

    if (company.text.isEmpty ||
        role.text.isEmpty ||
        location.text.isEmpty ||
        type.text.isEmpty ||
        salary.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor:
              Colors.red,

          content: const Text(
            "Fill all fields",
          ),
        ),
      );

      return;
    }

    setState(() => loading = true);

    try {

      await Supabase.instance.client
          .from('jobs')
          .insert({

        'company':
            company.text.trim(),

        'role':
            role.text.trim(),

        'location':
            location.text.trim(),

        'job_type':
            type.text.trim(),

        'salary':
            int.tryParse(
                  salary.text.trim(),
                ) ??
                0,

        'description':
            description.text.trim(),

        'created_at':
            DateTime.now()
                .toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor:
              AppTheme.primary,

          content: const Text(
            "Job posted successfully 🚀",
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor:
              Colors.red,

          content: Text(
            "Error: $e",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {

    company.dispose();
    role.dispose();
    location.dispose();
    type.dispose();
    salary.dispose();
    description.dispose();

    super.dispose();
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
                                BorderRadius
                                    .circular(
                                        18),
                          ),

                          child:
                              const Icon(
                            Icons
                                .arrow_back_ios_new,

                            color:
                                Colors
                                    .white,
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        "Add Job",

                        style:
                            TextStyle(
                          color:
                              Colors
                                  .white,

                          fontSize:
                              28,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),

                  const SizedBox(
                      height: 35),

                  // =========================
                  // MAIN CARD
                  // =========================

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets
                            .all(24),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white10,

                      borderRadius:
                          BorderRadius
                              .circular(
                                  32),

                      border:
                          Border.all(
                        color: Colors
                            .white12,
                      ),

                      boxShadow: [

                        BoxShadow(
                          color: Colors
                              .deepPurple
                              .withOpacity(
                                  0.25),

                          blurRadius:
                              30,

                          spreadRadius:
                              2,

                          offset:
                              const Offset(
                                  0,
                                  15),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        // =========================
                        // ICON
                        // =========================

                        Container(
                          padding:
                              const EdgeInsets
                                  .all(
                                      22),

                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape
                                    .circle,

                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                    0xff7B2FF7),

                                Color(
                                    0xff4A00E0),
                              ],
                            ),
                          ),

                          child:
                              const Icon(
                            Icons.work,

                            size: 60,

                            color:
                                Colors
                                    .white,
                          ),
                        ),

                        const SizedBox(
                            height: 25),

                        const Text(
                          "Post New Job 🚀",

                          style:
                              TextStyle(
                            color:
                                Colors.white,

                            fontSize:
                                30,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        const Text(
                          "Create professional job listings for candidates",

                          textAlign:
                              TextAlign
                                  .center,

                          style:
                              TextStyle(
                            color:
                                Colors
                                    .white70,

                            fontSize:
                                15,
                          ),
                        ),

                        const SizedBox(
                            height: 30),

                        // =========================
                        // FIELDS
                        // =========================

                        _field(
                          company,
                          "Company Name",
                          Icons.business,
                        ),

                        _field(
                          role,
                          "Job Role",
                          Icons.work,
                        ),

                        _field(
                          location,
                          "Location",
                          Icons.location_on,
                        ),

                        _field(
                          type,
                          "Job Type",
                          Icons.category,
                        ),

                        _field(
                          salary,
                          "Salary",
                          Icons.currency_rupee,
                        ),

                        _field(
                          description,
                          "Description",
                          Icons.description,

                          maxLines: 4,
                        ),

                        const SizedBox(
                            height: 25),

                        // =========================
                        // BUTTON
                        // =========================

                        GestureDetector(
                          onTap: loading
                              ? null
                              : addJob,

                          child:
                              Container(
                            width: double
                                .infinity,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical:
                                  18,
                            ),

                            decoration:
                                BoxDecoration(

                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(
                                      0xff7B2FF7),

                                  Color(
                                      0xffE940FF),
                                ],
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          22),

                              boxShadow: [

                                BoxShadow(
                                  color: Colors
                                      .purple
                                      .withOpacity(
                                          0.45),

                                  blurRadius:
                                      25,

                                  spreadRadius:
                                      2,
                                ),
                              ],
                            ),

                            child:
                                Center(
                              child: loading

                                  ? const SizedBox(
                                      height:
                                          24,

                                      width:
                                          24,

                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.white,

                                        strokeWidth:
                                            2.5,
                                      ),
                                    )

                                  : const Text(
                                      "Post Job",

                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,

                                        fontSize:
                                            20,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
  // FIELD
  // =========================

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 16),

      child: TextField(
        controller: controller,

        maxLines: maxLines,

        style:
            const TextStyle(
          color: Colors.white,
        ),

        keyboardType:
            label == "Salary"

                ? TextInputType.number

                : TextInputType.text,

        decoration:
            InputDecoration(
          hintText: label,

          prefixIcon: Icon(
            icon,
            color:
                Colors.white70,
          )
        ),
      ),
    );
  }
}