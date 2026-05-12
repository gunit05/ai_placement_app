import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends StatelessWidget {
  final String username;

  const PremiumScreen({
    super.key,
    required this.username,
  });

  final String upiId =
      '6205449441@naviaxis';

  final int originalPrice = 399;
  final int offerPrice = 199;

  Future<void> openUPI() async {

    final Uri uri = Uri.parse(
      'upi://pay?pa=6205449441@naviaxis&pn=AI%20Placement%20App&am=199&cu=INR',
    );

    try {

      await launchUrl(
        uri,

        mode:
            LaunchMode.externalApplication,
      );

    } catch (e) {

      debugPrint(
        "UPI Error: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xff040B2D),

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

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

                    child: Container(
                      padding:
                          const EdgeInsets
                              .all(12),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white10,

                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),

                      child: const Icon(
                        Icons
                            .arrow_back_ios_new,

                        color:
                            Colors.white,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    "Premium",

                    style: TextStyle(
                      color:
                          Colors.white,

                      fontSize: 30,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const Spacer(),
                ],
              ),

              const SizedBox(height: 30),

              // =========================
              // HERO CARD
              // =========================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets
                        .all(28),

                decoration:
                    BoxDecoration(

                  borderRadius:
                      BorderRadius
                          .circular(35),

                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,

                    end: Alignment
                        .bottomRight,

                    colors: [
                      Color(0xff7B2FF7),
                      Color(0xff4A00E0),
                    ],
                  ),

                  boxShadow: [

                    BoxShadow(
                      color: Colors
                          .deepPurple
                          .withOpacity(
                              0.45),

                      blurRadius: 30,

                      spreadRadius: 5,

                      offset:
                          const Offset(
                              0, 15),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .center,
                          children: 
                      [
                    const Text(
                      "Unlock Premium",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color:
                            Colors.white,

                        fontSize: 34,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    const Text(
                      "AI Powered Career Growth Features",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color:
                            Colors.white70,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                        height: 25),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.orange,

                        borderRadius:
                            BorderRadius
                                .circular(
                                    30),
                      ),

                      child: const Text(
                        "🔥 50% OFF LIMITED OFFER",

                        style: TextStyle(
                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 25),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        Text(
                          "₹$originalPrice",

                          style:
                              const TextStyle(
                            color: Colors
                                .white54,

                            fontSize: 24,

                            decoration:
                                TextDecoration
                                    .lineThrough,
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        Text(
                          "₹$offerPrice",

                          style:
                              const TextStyle(
                            color:
                                Colors.white,

                            fontSize: 42,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // FEATURES
              // =========================

              const Text(
                "Premium Features",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              premiumFeature(
                Icons.smart_toy,
                "Advanced AI Chatbot",
                "Unlimited AI guidance & smart answers",
              ),

              premiumFeature(
                Icons.mic,
                "AI Mock Interview",
                "Real-time voice interview simulation",
              ),

              premiumFeature(
                Icons.analytics,
                "Resume Analysis",
                "Detailed ATS resume analysis",
              ),

              premiumFeature(
                Icons.workspace_premium,
                "Premium Badge",
                "Get verified premium badge",
              ),

              premiumFeature(
                Icons.work,
                "Job Tracking",
                "Track all applications professionally",
              ),

              const SizedBox(height: 30),

              // =========================
              // PAYMENT CARD
              // =========================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets
                        .all(24),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white10,

                  borderRadius:
                      BorderRadius
                          .circular(30),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    const Text(
                      "Payment Details",

                      style: TextStyle(
                        color:
                            Colors.white,

                        fontSize: 24,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    paymentRow(
                      "UPI ID",
                      upiId,
                    ),

                    paymentRow(
                      "Offer Price",
                      "₹199",
                    ),

                    paymentRow(
                      "Discount",
                      "50% OFF",
                    ),

                    paymentRow(
                      "Validity",
                      "Lifetime",
                    ),

                    const SizedBox(
                        height: 25),

                    GestureDetector(
                      onTap: openUPI,

                      child: Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 18,
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
                            const Center(
                          child: Text(
                            "Pay ₹199 Now",

                            style:
                                TextStyle(
                              color: Colors
                                  .white,

                              fontSize:
                                  20,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // FEATURE TILE
  // =========================

  Widget premiumFeature(
    IconData icon,
    String title,
    String subtitle,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 15),

      child: Container(
        padding:
            const EdgeInsets.all(
                18),

        decoration: BoxDecoration(
          color: Colors.white10,

          borderRadius:
              BorderRadius.circular(
                  24),
        ),

        child: Row(
          children: [

            Container(
              padding:
                  const EdgeInsets
                      .all(14),

              decoration:
                  BoxDecoration(
                color:
                    Colors.deepPurple,

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

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    title,

                    style:
                        const TextStyle(
                      color:
                          Colors.white,

                      fontSize: 18,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  Text(
                    subtitle,

                    style:
                        const TextStyle(
                      color:
                          Colors.white70,

                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PAYMENT ROW
  // =========================

  Widget paymentRow(
    String title,
    String value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 14),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(
            title,

            style:
                const TextStyle(
              color:
                  Colors.white70,

              fontSize: 15,
            ),
          ),

          Text(
            value,

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
    );
  }
}