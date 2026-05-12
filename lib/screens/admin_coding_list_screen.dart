import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/premium_ui.dart';

class AdminCodingListScreen extends StatefulWidget {
  const AdminCodingListScreen({super.key});

  @override
  State<AdminCodingListScreen> createState() =>
      _AdminCodingListScreenState();
}

class _AdminCodingListScreenState
    extends State<AdminCodingListScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filtered = [];

  bool loading = true;
  String search = "";

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
      final res = await supabase
          .from('coding_interviews')
          .select()
          .order('created_at', ascending: false);

      data = List<Map<String, dynamic>>.from(res);
      applyFilter();
    } catch (e) {
      debugPrint("FETCH ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading data"),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void applyFilter() {
    filtered = data.where((item) {
      final name =
          (item['username'] ?? "")
              .toString()
              .toLowerCase();

      final question =
          (item['question'] ?? "")
              .toString()
              .toLowerCase();

      return name.contains(
            search.toLowerCase(),
          ) ||
          question.contains(
            search.toLowerCase(),
          );
    }).toList();
  }

  void showCodeDialog(
    Map<String, dynamic> item,
  ) {
    final output = item['output'] ?? "";
    final code = item['code'] ?? "";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: PremiumCard(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "${item['username']} Submission",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "💻 Code",
                  style: TextStyle(
                    color:
                        Colors.deepPurpleAccent,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                  child: Text(
                    code,
                    style:
                        const TextStyle(
                      color:
                          Colors.greenAccent,
                      fontFamily:
                          'monospace',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "📊 Output",
                  style: TextStyle(
                    color:
                        Colors.orangeAccent,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  output,
                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                PremiumButton(
                  text: "Close",
                  icon: Icons.close,
                  onTap: () =>
                      Navigator.pop(
                          context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScreen(
      title: "Coding Reviews",
      subtitle:
          "Admin coding interview submissions",
      icon: Icons.code,
      scrollable: false,
      actions: [
        IconButton(
          onPressed: fetchData,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ],
      child: Column(
        children: [
          PremiumCard(
            padding:
                const EdgeInsets.all(14),
            child: TextField(
              onChanged: (val) {
                search = val;
                applyFilter();
                setState(() {});
              },
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration:
                  const InputDecoration(
                hintText:
                    "Search user/question...",
                hintStyle:
                    TextStyle(
                  color:
                      Colors.white54,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          AppTheme.primary,
                    ),
                  )
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No Submissions Found",
                          style: TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchData,
                        child:
                            ListView.builder(
                          itemCount:
                              filtered.length,
                          itemBuilder:
                              (_, index) {
                            final item =
                                filtered[index];

                            final output =
                                item['output'] ??
                                    "";

                            final language =
                                item['language'] ??
                                    "Unknown";

                            final correct =
                                output.contains(
                                    "✅");

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                      bottom:
                                          16),
                              child:
                                  GestureDetector(
                                onTap: () =>
                                    showCodeDialog(
                                  item,
                                ),
                                child:
                                    PremiumCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.all(
                                                14),
                                        decoration:
                                            BoxDecoration(
                                          gradient:
                                              LinearGradient(
                                            colors: correct
                                                ? [
                                                    Colors.green,
                                                    Colors.teal
                                                  ]
                                                : [
                                                    Colors.red,
                                                    Colors.pink
                                                  ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  18),
                                        ),
                                        child:
                                            Icon(
                                          correct
                                              ? Icons.check
                                              : Icons.close,
                                          color:
                                              Colors.white,
                                        ),
                                      ),

                                      const SizedBox(
                                          width:
                                              16),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['username'] ??
                                                  "Unknown",
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize:
                                                    17,
                                              ),
                                            ),

                                            const SizedBox(
                                                height:
                                                    6),

                                            Text(
                                              item['question'] ??
                                                  "",
                                              maxLines:
                                                  2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white70,
                                              ),
                                            ),

                                            const SizedBox(
                                                height:
                                                    6),

                                            Text(
                                              "Language: $language",
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.deepPurpleAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons
                                            .arrow_forward_ios,
                                        color:
                                            Colors.white54,
                                      ),
                                    ],
                                  ),
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