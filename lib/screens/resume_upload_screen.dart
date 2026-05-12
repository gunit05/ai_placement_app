import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ResumeUploadScreen extends StatefulWidget {
  final String username;

  const ResumeUploadScreen({
    super.key,
    required this.username,
  });

  @override
  State<ResumeUploadScreen> createState() =>
      _ResumeUploadScreenState();
}

class _ResumeUploadScreenState
    extends State<ResumeUploadScreen> {
  Uint8List? fileBytes;
  String? fileName;
  bool uploading = false;
  String selectedRole = "Loading...";

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final res = await Supabase.instance.client
        .from('user_skills')
        .select('recommended_role')
        .eq('username', widget.username)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      selectedRole =
          res?['recommended_role'] ?? "Software Engineer";
    });
  }

  String cleanText(String text) {
    return text.replaceAll(RegExp(r'[\u0000]'), '');
  }

  Map<String, dynamic> analyzeATS(
      String resumeText, List<String> skills) {
    int match = 0;
    List<String> missing = [];

    for (var skill in skills) {
      if (resumeText
          .toLowerCase()
          .contains(skill.toLowerCase())) {
        match++;
      } else {
        missing.add(skill);
      }
    }

    int total = skills.isEmpty ? 1 : skills.length;
    int score = ((match / total) * 100).round();

    return {
      "score": score,
      "missing": missing,
      "suggestions": missing.isEmpty
          ? "Excellent Resume 🚀"
          : "Missing: ${missing.join(', ')}",
    };
  }

  Future<void> pickResume() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        fileBytes = result.files.single.bytes;
        fileName = result.files.single.name;
      });
    }
  }

  Future<void> uploadResume() async {
    if (fileBytes == null) return;

    setState(() => uploading = true);

    try {
      final path =
          'resumes/${widget.username}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Supabase.instance.client.storage
          .from('resumes')
          .uploadBinary(path, fileBytes!);

      final fileUrl = Supabase.instance.client.storage
          .from('resumes')
          .getPublicUrl(path);

      final doc = PdfDocument(inputBytes: fileBytes!);
      String text = PdfTextExtractor(doc).extractText();
      doc.dispose();

      text = cleanText(text);

      final userData = await Supabase.instance.client
          .from('user_skills')
          .select('skills')
          .eq('username', widget.username)
          .maybeSingle();

      List<String> skills =
          List<String>.from(userData?['skills'] ?? []);

      final ats = analyzeATS(text, skills);

      await Supabase.instance.client
          .from('resume_uploads')
          .insert({
        'username': widget.username,
        'file_url': fileUrl,
        'resume_text': text,
      });

      await Supabase.instance.client
          .from('resume_scores')
          .upsert({
        'username': widget.username,
        'score': ats['score'],
        'missing_skills': ats['missing'].join(', '),
        'suggestions': ats['suggestions'],
      }, onConflict: 'username');

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xff111C44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "ATS Result 🚀",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Score: ${ats['score']}%",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ats['suggestions'],
                style: const TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      setState(() {
        fileBytes = null;
        fileName = null;
      });

    } catch (e) {
      debugPrint("ERROR: $e");
    }

    setState(() => uploading = false);
  }

  Widget gradientCard({
    required Widget child,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040B2D),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Resume Analyzer 📄",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            gradientCard(
              colors: const [
                Color(0xff7B2FF7),
                Color(0xffE940FF),
              ],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Target Role:\n$selectedRole",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: pickResume,
              child: gradientCard(
                colors: const [
                  Color(0xff00C9FF),
                  Color(0xff92FE9D),
                ],
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        color: Colors.white,
                        size: 70,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        fileName ??
                            "Tap to Upload PDF Resume",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed:
                    uploading ? null : uploadResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                child: uploading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Analyze Resume 🚀",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}