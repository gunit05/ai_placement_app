import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../theme/premium_ui.dart';

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
    try {
      final res = await Supabase.instance.client
          .from('user_skills')
          .select('recommended_role')
          .eq('username', widget.username)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        selectedRole =
            res?['recommended_role'] ??
                "Software Engineer";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        selectedRole = "Software Engineer";
      });
    }
  }

  String cleanText(String text) {
    return text.replaceAll(
      RegExp(r'[\u0000]'),
      '',
    );
  }

  Map<String, dynamic> analyzeATS(
    String resumeText,
    List<String> skills,
  ) {
    int match = 0;
    List<String> missing = [];

    for (final skill in skills) {
      if (resumeText
          .toLowerCase()
          .contains(skill.toLowerCase())) {
        match++;
      } else {
        missing.add(skill);
      }
    }

    final total =
        skills.isEmpty ? 1 : skills.length;

    final score =
        ((match / total) * 100).round();

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

    if (result != null && mounted) {
      setState(() {
        fileBytes = result.files.single.bytes;
        fileName = result.files.single.name;
      });
    }
  }

  Future<void> uploadResume() async {
    if (fileBytes == null || uploading) return;

    setState(() => uploading = true);

    try {
      final path =
          'resumes/${widget.username}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Supabase.instance.client.storage
          .from('resumes')
          .uploadBinary(path, fileBytes!);

      final fileUrl = Supabase
          .instance.client.storage
          .from('resumes')
          .getPublicUrl(path);

      final doc = PdfDocument(
        inputBytes: fileBytes!,
      );

      String text =
          PdfTextExtractor(doc).extractText();

      doc.dispose();

      text = cleanText(text);

      final userData = await Supabase
          .instance.client
          .from('user_skills')
          .select('skills')
          .eq('username', widget.username)
          .maybeSingle();

      final skills = List<String>.from(
        userData?['skills'] ?? [],
      );

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
        'missing_skills':
            ats['missing'].join(', '),
        'suggestions': ats['suggestions'],
      }, onConflict: 'username');

      if (!mounted) return;

      final isDark =
          Theme.of(context).brightness ==
              Brightness.dark;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor:
              isDark
                  ? AppTheme.darkCard
                  : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: Text(
            "ATS Result 🚀",
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                "Score: ${ats['score']}%",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ats['suggestions'],
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : Colors.black54,
                ),
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
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              AppTheme.primary,
          content: Text(
            "Upload failed: $e",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => uploading = false);
    }
  }

  Widget glow(
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

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppTheme.darkBg
              : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: glow(
              260,
              AppTheme.primary.withOpacity(
                0.22,
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(
              300,
              Colors.blue.withOpacity(
                0.10,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                children: [
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
                            color: isDark
                                ? Colors
                                    .white10
                                : Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        18),
                          ),
                          child: Icon(
                            Icons
                                .arrow_back_ios_new,
                            color: isDark
                                ? Colors.white
                                : Colors
                                    .black87,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Resume Analyzer",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  PremiumCard(
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .all(14),
                          decoration:
                              BoxDecoration(
                            gradient: AppTheme
                                .primaryGradient,
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color:
                                Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                            width: 14),
                        Expanded(
                          child: Text(
                            "Target Role:\n$selectedRole",
                            style: TextStyle(
                              color: isDark
                                  ? Colors
                                      .white
                                  : Colors
                                      .black87,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: pickResume,
                    child: Container(
                      width: double.infinity,
                      height: 260,
                      decoration:
                          BoxDecoration(
                        gradient: AppTheme
                            .aiGradient,
                        borderRadius:
                            BorderRadius
                                .circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme
                                .primary
                                .withOpacity(
                                    0.25),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons.cloud_upload,
                            color:
                                Colors.white,
                            size: 72,
                          ),
                          const SizedBox(
                              height: 18),
                          Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              fileName ??
                                  "Tap to Upload PDF Resume",
                              textAlign:
                                  TextAlign
                                      .center,
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  PremiumButton(
                    text: uploading
                        ? "Analyzing..."
                        : "Analyze Resume 🚀",
                    icon:
                        Icons.analytics,
                    onTap: uploading
                        ? () {}
                        : uploadResume,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}