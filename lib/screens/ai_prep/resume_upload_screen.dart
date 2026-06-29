import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:hire_hub/theme/premium_ui.dart';

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

  final String groqApiKey =
      dotenv.env['GROQ_API_KEY'] ?? "";

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
          ? "Excellent Resume"
          : "Missing: ${missing.join(', ')}",
    };
  }

  Future<Map<String, dynamic>> analyzeWithGroq(
    String resumeText,
  ) async {
    try {
      if (groqApiKey.isEmpty) {
        return {
          "ai_score": 0,
          "suggestions":
              "Groq API key missing",
          "strengths": "",
        };
      }

      final response = await http.post(
        Uri.parse(
          'https://api.groq.com/openai/v1/chat/completions',
        ),
        headers: {
          'Authorization':
              'Bearer $groqApiKey',
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "temperature": 0.2,
          "messages": [
            {
              "role": "system",
              "content":
                  "Return ONLY valid JSON."
            },
            {
              "role": "user",
              "content": """
Analyze this resume for ATS.

Role: $selectedRole

Return exact JSON:
{
 "ai_score": 85,
 "suggestions": "Improve formatting",
 "strengths": "Good technical profile"
}

Resume:
$resumeText
"""
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        return {
          "ai_score": 0,
          "suggestions":
              "Groq request failed",
          "strengths": "",
        };
      }

      final data =
          jsonDecode(response.body);

      String content =
          data['choices'][0]['message']
                  ['content']
              .toString();

      content = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(content);
    } catch (_) {
      return {
        "ai_score": 0,
        "suggestions":
            "AI analysis unavailable",
        "strengths": "",
      };
    }
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
        fileBytes =
            result.files.single.bytes;
        fileName =
            result.files.single.name;
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

      final fileUrl = Supabase.instance.client
          .storage
          .from('resumes')
          .getPublicUrl(path);

      final doc = PdfDocument(
        inputBytes: fileBytes!,
      );

      String text =
          PdfTextExtractor(doc).extractText();

      doc.dispose();

      text = cleanText(text);

      final userData =
          await Supabase.instance.client
              .from('user_skills')
              .select('skills')
              .eq('username', widget.username)
              .maybeSingle();

      final skills = List<String>.from(
        userData?['skills'] ?? [],
      );

      final manualATS =
          analyzeATS(text, skills);

      final aiATS =
          await analyzeWithGroq(text);

      await Supabase.instance.client
          .from('resume_uploads')
          .insert({
        'username': widget.username,
        'file_url': fileUrl,
        'resume_text': text,
        'created_at': DateTime.now()
            .toIso8601String(),
      });

      await Supabase.instance.client
          .from('resume_scores')
          .upsert({
        'username': widget.username,
        'score': manualATS['score'],
        'missing_skills':
            manualATS['missing'].join(', '),
        'suggestions':
            manualATS['suggestions'],
        'ai_score':
            aiATS['ai_score'],
        'ai_suggestions':
            aiATS['suggestions'],
        'strengths':
            aiATS['strengths'],
        'ats_type': 'hybrid',
        'admin_override': false,
      }, onConflict: 'username');

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:
              const Text("Hybrid ATS Complete"),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                "Manual ATS: ${manualATS['score']}%",
              ),
              const SizedBox(height: 10),
              Text(
                "AI ATS: ${aiATS['ai_score']}%",
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
          content: Text("$e"),
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
      backgroundColor: isDark
          ? AppTheme.darkBg
          : AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: glow(
              260,
              AppTheme.primary.withValues(
                  alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: glow(
              300,
              Colors.blue.withValues(
                  alpha: 0.10),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Hybrid ATS Analyzer",
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PremiumCard(
                    child: Text(
                      "Target Role: $selectedRole",
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
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
                        gradient:
                            AppTheme.aiGradient,
                        borderRadius:
                            BorderRadius
                                .circular(30),
                      ),
                      child: Center(
                        child: Text(
                          fileName ??
                              "Upload PDF Resume",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PremiumButton(
                    text: uploading
                        ? "Analyzing..."
                        : "Analyze Resume",
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