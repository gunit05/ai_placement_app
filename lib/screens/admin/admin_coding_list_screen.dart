import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire_hub/theme/premium_ui.dart';

class AdminCodingListScreen extends StatefulWidget {
  const AdminCodingListScreen({super.key});

  @override
  State<AdminCodingListScreen> createState() => _AdminCodingListScreenState();
}

class _AdminCodingListScreenState extends State<AdminCodingListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> data = [], filtered = [];
  bool loading = true;
  String search = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (mounted) setState(() => loading = true);
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
          const SnackBar(content: Text("Error loading data")),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  void applyFilter() {
    filtered = data.where((item) {
      final name = (item['username'] ?? "").toString().toLowerCase();
      final question = (item['question'] ?? "").toString().toLowerCase();
      return name.contains(search.toLowerCase()) ||
          question.contains(search.toLowerCase());
    }).toList();
  }

  void showCodeDialog(Map<String, dynamic> item) {
    final output = item['output'] ?? "";
    final code = item['code'] ?? "";
    final textColor = Theme.of(context).colorScheme.onBackground;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: PremiumCard(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['username']} Submission",
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text("💻 Code", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                  child: Text(code,
                      style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
                ),
                const SizedBox(height: 16),
                Text("📊 Output", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(output, style: TextStyle(color: textColor)),
                const SizedBox(height: 16),
                PremiumButton(text: "Close", icon: Icons.close, onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumScreen(
      title: "Coding Reviews",
      subtitle: "Admin coding interview submissions",
      icon: Icons.code,
      scrollable: false,
      actions: [
        IconButton(onPressed: fetchData, icon: Icon(Icons.refresh, color: textColor)),
      ],
      child: Column(
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) {
                search = val;
                applyFilter();
                setState(() {});
              },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search user/question...",
                hintStyle: TextStyle(color: secondaryColor),
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : filtered.isEmpty
                    ? Center(
                        child: Text("No Submissions Found",
                            style: TextStyle(color: secondaryColor, fontSize: 16)),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchData,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, index) {
                            final item = filtered[index];
                            final output = item['output'] ?? "";
                            final language = item['language'] ?? "Unknown";
                            final correct = output.contains("✅");

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => showCodeDialog(item),
                                child: PremiumCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: correct
                                                ? [Colors.green, Colors.teal]
                                                : [Colors.red, Colors.pink],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(correct ? Icons.check : Icons.close, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['username'] ?? "Unknown",
                                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(item['question'] ?? "",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: secondaryColor)),
                                            const SizedBox(height: 4),
                                            Text("Language: $language",
                                                style: const TextStyle(color: Colors.deepPurpleAccent)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios, color: secondaryColor),
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
