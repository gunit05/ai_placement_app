import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  const PdfViewerScreen({super.key, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {

  String? path;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final res = await http.get(Uri.parse(widget.url));

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/resume.pdf");

      await file.writeAsBytes(res.bodyBytes);

      if (!mounted) return;

      setState(() {
        path = file.path;
        loading = false;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading PDF")),
      );
    }
  }

  Future<void> shareFile() async {
    if (path != null) {
      await Share.shareXFiles([XFile(path!)]);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resume"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareFile,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : PDFView(filePath: path!),
    );
  }
}