import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';
import 'admin_resume_score_screen.dart';
import 'pdf_viewer_screen.dart';

class AdminResumeListScreen extends StatefulWidget {
  const AdminResumeListScreen({super.key});

  @override
  State<AdminResumeListScreen> createState() =>
      _AdminResumeListScreenState();
}

class _AdminResumeListScreenState
    extends State<AdminResumeListScreen> {
  List<Map<String, dynamic>> allResumes = [];
  List<Map<String, dynamic>> filteredResumes = [];

  bool loading = true;
  String search = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() => loading = true);
    }

    try {
      final data = await Supabase.instance.client
          .from('resume_uploads')
          .select()
          .order('created_at', ascending: false);

      allResumes = List<Map<String, dynamic>>.from(data);
      filteredResumes = allResumes;
    } catch (e) {
      debugPrint("RESUME ERROR: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void applySearch(String value) {
    setState(() {
      search = value;

      filteredResumes = allResumes.where((r) {
        final name =
            (r['username'] ?? "")
                .toString()
                .toLowerCase();

        return name.contains(
          value.toLowerCase(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "Resume Reviews",
      subtitle: "Admin resume submissions",
      icon: Icons.picture_as_pdf,
      scrollable: false,
      actions: [
        IconButton(
          onPressed: loadData,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ],
      child: Column(
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: applySearch,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: "Search by username...",
                hintStyle: TextStyle(
                  color: Colors.white54,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  )
                : filteredResumes.isEmpty
                    ? const Center(
                        child: Text(
                          "No resumes found",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadData,
                        child: ListView.builder(
                          itemCount:
                              filteredResumes.length,
                          itemBuilder: (_, i) {
                            final r =
                                filteredResumes[i];

                            final username =
                                r['username'] ??
                                    "Unknown";

                            final date =
                                r['created_at'] !=
                                        null
                                    ? r['created_at']
                                        .toString()
                                        .substring(
                                            0, 10)
                                    : "";

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                      bottom:
                                          16),
                              child:
                                  PremiumCard(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(
                                                      16),
                                          decoration:
                                              BoxDecoration(
                                            gradient:
                                                const LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.pink,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red
                                                    .withOpacity(
                                                        0.35),
                                                blurRadius:
                                                    18,
                                              ),
                                            ],
                                          ),
                                          child:
                                              const Icon(
                                            Icons
                                                .picture_as_pdf,
                                            color:
                                                Colors.white,
                                            size:
                                                30,
                                          ),
                                        ),

                                        const SizedBox(
                                            width:
                                                16),

                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                username,
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white,
                                                  fontSize:
                                                      17,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      4),
                                              Text(
                                                "Uploaded: $date",
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height:
                                            18),

                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              PremiumButton(
                                            text:
                                                "View",
                                            icon: Icons
                                                .visibility,
                                            onTap:
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          PdfViewerScreen(
                                                    url:
                                                        r['file_url'],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(
                                            width:
                                                12),

                                        Expanded(
                                          child:
                                              PremiumButton(
                                            text:
                                                "Analyze",
                                            icon: Icons
                                                .analytics,
                                            onTap:
                                                () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          AdminResumeScoreScreen(
                                                    username:
                                                        username,
                                                  ),
                                                ),
                                              );
                                            },
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
                      ),
          ),
        ],
      ),
    );
  }
}