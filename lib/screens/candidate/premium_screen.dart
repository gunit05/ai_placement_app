import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hire_hub/theme/premium_ui.dart';

class PremiumScreen extends StatelessWidget {
  final String username;

  const PremiumScreen({
    super.key,
    required this.username,
  });

  final String upiId = '6205449441@naviaxis';
  final int originalPrice = 399;
  final int offerPrice = 199;

  Future<void> openUPI() async {
    final Uri uri = Uri.parse(
      'upi://pay?pa=6205449441@naviaxis&pn=AI%20Placement%20App&am=199&cu=INR',
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  Widget premiumFeature(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : Colors.black54,
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

  Widget paymentRow(
    BuildContext context,
    String title,
    String value,
  ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            child: _glow(
              260,
              AppTheme.primary.withOpacity(0.22),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _glow(
              300,
              Colors.blue.withOpacity(0.10),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pop(context),
                        child: Container(
                          padding:
                              const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Premium",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(35),
                      gradient:
                          AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary
                              .withOpacity(0.45),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset:
                              const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Unlock Premium",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "AI Powered Career Growth Features",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius:
                                BorderRadius.circular(
                                    30),
                          ),
                          child: const Text(
                            "🔥 50% OFF LIMITED OFFER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              "₹$originalPrice",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 24,
                                decoration:
                                    TextDecoration
                                        .lineThrough,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "₹$offerPrice",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Premium Features",
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  premiumFeature(
                    context,
                    Icons.smart_toy,
                    "Advanced AI Chatbot",
                    "Unlimited AI guidance & smart answers",
                  ),
                  premiumFeature(
                    context,
                    Icons.mic,
                    "AI Mock Interview",
                    "Real-time voice interview simulation",
                  ),
                  premiumFeature(
                    context,
                    Icons.analytics,
                    "Resume Analysis",
                    "Detailed ATS resume analysis",
                  ),
                  premiumFeature(
                    context,
                    Icons.workspace_premium,
                    "Premium Badge",
                    "Get verified premium badge",
                  ),
                  premiumFeature(
                    context,
                    Icons.work,
                    "Job Tracking",
                    "Track all applications professionally",
                  ),

                  const SizedBox(height: 30),

                  PremiumCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Details",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        paymentRow(
                          context,
                          "UPI ID",
                          upiId,
                        ),
                        paymentRow(
                          context,
                          "Offer Price",
                          "₹199",
                        ),
                        paymentRow(
                          context,
                          "Discount",
                          "50% OFF",
                        ),
                        paymentRow(
                          context,
                          "Validity",
                          "Lifetime",
                        ),
                        const SizedBox(height: 24),
                        PremiumButton(
                          text: "Pay ₹199 Now",
                          icon:
                              Icons.account_balance_wallet,
                          onTap: openUPI,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(
    double size,
    Color color,
  ) {
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