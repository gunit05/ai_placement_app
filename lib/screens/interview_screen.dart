import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'interview_result_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/theme_controller.dart';

class InterviewScreen extends StatefulWidget {
  final String username;
  const InterviewScreen({super.key, required this.username});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  CameraController? cameraController;
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  final supabase = Supabase.instance.client;

  Timer? timer;
  bool isListening = false, isMuted = false, micEnabled = true, isSubmitting = false;
  bool cameraReady = false, recordingStarted = false, loadingQuestions = true;

  int index = 0, seconds = 45, liveScore = 0;
  String liveAnswer = "";
  List<String> userSkills = [];
  List<String> questions = [];
  List<Map<String, dynamic>> answers = [];

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    await initCamera();
    await initSpeech();
    await loadQuestions();
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        await cameraController!.startVideoRecording();
        recordingStarted = true;
      } catch (_) {}
    }
    if (questions.isNotEmpty) {
      if (!isMuted) {
        await speakQuestion();
      } else if (micEnabled) {
        await startListening();
      }
      startTimer();
    }
  }

  Future<void> loadQuestions() async {
    try {
      final res = await supabase.from('user_skills').select().eq('username', widget.username).maybeSingle();
      if (res != null && res['skills'] != null) userSkills = List<String>.from(res['skills']);
      if (userSkills.isEmpty) userSkills = ["Flutter", "Java", "Python", "DSA", "Database"];

      final prompt = """
Generate exactly 10 interview questions.
Rules:
- First 5 must be TECHNICAL based on: ${userSkills.join(", ")}
- Last 5 must be HR interview questions
Return ONLY valid JSON array.
""";

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": "You generate interview questions in JSON only."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiText = data['choices'][0]['message']['content'];
        aiText = aiText.replaceAll("```json", "").replaceAll("```", "").trim();
        questions = List<String>.from(jsonDecode(aiText));
      } else {
        throw Exception("API failed");
      }
    } catch (_) {
      questions = [
        "Explain Flutter widget lifecycle.",
        "Difference between Future and Stream?",
        "Explain OOP principles.",
        "What is normalization in DBMS?",
        "What is time complexity?",
        "Tell me about yourself.",
        "Why should we hire you?",
        "What are your strengths?",
        "How do you handle pressure?",
        "Where do you see yourself in 5 years?"
      ];
    }
    if (mounted) setState(() => loadingQuestions = false);
  }

  Future<void> initSpeech() async => await speech.initialize();

  Future<void> initCamera() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first);
      cameraController = CameraController(front, ResolutionPreset.medium, enableAudio: true);
      await cameraController!.initialize();
      if (mounted) setState(() => cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => cameraReady = false);
    }
  }

  Future<void> speakQuestion() async {
    await stopListening();
    await tts.stop();
    await tts.setLanguage("en-IN");
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    tts.setCompletionHandler(() async {
      if (micEnabled) await startListening();
    });
    await tts.speak(questions[index]);
  }

  Future<void> startListening() async {
    if (!micEnabled || isListening) return;
    final available = await speech.initialize();
    if (!available) return;
    isListening = true;
    if (mounted) setState(() {});
    speech.listen(
      localeId: "en_IN",
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          liveAnswer = result.recognizedWords;
          liveScore = calculateScore(liveAnswer);
        });
      },
    );
  }

  Future<void> stopListening() async {
    if (!isListening) return;
    await speech.stop();
    isListening = false;
    if (mounted) setState(() {});
  }

  void toggleSpeaker() async {
    setState(() => isMuted = !isMuted);
    if (isMuted) {
      await tts.stop();
    } else {
      await speakQuestion();
    }
  }

  void toggleMic() async {
    setState(() => micEnabled = !micEnabled);
    if (!micEnabled) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  int calculateScore(String text) {
    final len = text.trim().length;
    if (len > 150) return 95;
    if (len > 100) return 85;
    if (len > 60) return 75;
    if (len > 25) return 55;
    return 20;
  }

  Future<void> typeAnswerDialog() async {
    final textController = TextEditingController(text: liveAnswer);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Type Answer", style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        content: TextField(
          controller: textController,
          maxLines: 6,
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          decoration: InputDecoration(
            hintText: "Enter answer",
            hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                liveAnswer = textController.text;
                liveScore = calculateScore(liveAnswer);
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (seconds <= 0) {
        await nextQuestion();
      } else {
        if (!mounted) return;
        setState(() => seconds--);
      }
    });
  }

  Future<void> nextQuestion() async {
    await stopListening();
    timer?.cancel();
    answers.add({
      "question": questions[index],
      "answer": liveAnswer.isEmpty ? "No answer" : liveAnswer,
      "score": liveScore,
      "type": index < 5 ? "technical" : "hr",
    });
    liveAnswer = "";
    liveScore = 0;
    if (index < questions.length - 1) {
      index++;
      seconds = 45;
      if (mounted) setState(() {});
      if (!isMuted) {
        await speakQuestion();
      } else if (micEnabled) {
        await startListening();
      }
      startTimer();
    } else {
      await finish();
    }
  }

   Future<void> finish() async {
    if (isSubmitting) return;
    isSubmitting = true;

    await stopListening();
    await tts.stop();
    timer?.cancel();

    int total = answers.fold(0, (sum, a) => sum + (a['score'] as int));
    final finalScore = answers.isEmpty ? 0 : (total / answers.length).round();

    String? videoUrl;
    try {
      if (recordingStarted &&
          cameraController != null &&
          cameraController!.value.isRecordingVideo) {
        final file = await cameraController!.stopVideoRecording();
        videoUrl = await uploadVideo(file.path);
      }
    } catch (_) {}

    try {
      await supabase.from('interview_results').insert({
        'username': widget.username,
        'answers': answers,
        'score': finalScore,
        'video_url': videoUrl,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InterviewResultScreen(
            score: finalScore,
            username: widget.username,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed")),
      );
    }
  }

  Future<String?> uploadVideo(String filePath) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/did6skwfo/video/upload");
      final request = http.MultipartRequest("POST", uri);
      request.fields['upload_preset'] = 'interview_upload';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      if (response.statusCode != 200) return null;
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);
      return data['secure_url'];
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    speech.stop();
    tts.stop();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loadingQuestions
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : cameraReady
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                            ),
                            const Spacer(),
                            Text("AI Interview",
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton(
                              onPressed: finish,
                              child: const Text("Submit", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.40,
                            width: double.infinity,
                            color: Theme.of(context).cardColor,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: cameraController!.value.previewSize!.height,
                                height: cameraController!.value.previewSize!.width,
                                child: CameraPreview(cameraController!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Question ${index + 1}/10",
                                  style: TextStyle(
                                      color: index < 5
                                          ? Colors.cyanAccent
                                          : Colors.orangeAccent)),
                              const SizedBox(height: 10),
                              Text(questions[index],
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _smallCard(Icons.timer, "$seconds s", textColor)),
                            const SizedBox(width: 10),
                            Expanded(child: _smallCard(Icons.score, "$liveScore", textColor)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                liveAnswer.isEmpty
                                    ? "Speak or type your answer..."
                                    : liveAnswer,
                                style: TextStyle(color: secondaryColor, height: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionBtn(isMuted ? Icons.volume_off : Icons.volume_up,
                                "Speaker", toggleSpeaker),
                            _actionBtn(micEnabled ? Icons.mic : Icons.mic_off,
                                "Mic", toggleMic),
                            _actionBtn(Icons.keyboard, "Type", typeAnswerDialog),
                            _actionBtn(Icons.skip_next, "Next", nextQuestion),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
    );
  }

  Widget _smallCard(IconData icon, String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xff7B2FF7), Color(0xff4A00E0)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.deepPurple.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
