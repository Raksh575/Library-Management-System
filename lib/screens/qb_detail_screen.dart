import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class QuestionBankDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bank;
  const QuestionBankDetailScreen({super.key, required this.bank});

  @override
  State<QuestionBankDetailScreen> createState() => _QuestionBankDetailScreenState();
}

class _QuestionBankDetailScreenState extends State<QuestionBankDetailScreen> {
  bool _opening = false;
  String? _localPath;

  Future<String?> _downloadPdf(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/${url.split('/').last}";
      final file = File(filePath);
      if (!file.existsSync()) {
        await Dio().download(url, filePath);
      }
      return filePath;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _copyAssetToLocal(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final file = File('${(await getTemporaryDirectory()).path}/${assetPath.split('/').last}');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } on FlutterError {
      return null; // asset missing
    }
  }

  Future<void> _openPaper() async {
    if (_opening) return;
    setState(() => _opening = true);

    String? path;
    if (widget.bank['type'] == 'online') {
      final url = widget.bank['url'] as String?;
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
        setState(() => _opening = false);
        return;
      }
      path = await _downloadPdf(url);
    } else {
      final asset = widget.bank['file'] as String?;
      if (asset == null || asset.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No asset file configured')));
        setState(() => _opening = false);
        return;
      }
      path = await _copyAssetToLocal(asset);
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asset not found. Add the PDF under assets and pubspec.yaml')));
      }
    }

    setState(() => _opening = false);

    if (path != null) {
      _localPath = path;
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PDFScaffold(title: widget.bank['title'] as String? ?? 'Question Paper', filePath: path!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to prepare PDF')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.bank['title'] as String? ?? 'Question Bank';
    final author = widget.bank['author'] as String? ?? 'Unknown';
    final category = widget.bank['category'] as String? ?? 'General';
    final type = widget.bank['type'] as String? ?? 'online';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Author: $author'),
            Text('Category: $category'),
            Text('Type: ${type.toUpperCase()}'),
            const SizedBox(height: 20),
            if (type == 'online')
              Text('URL: ${widget.bank['url'] ?? '-'}', style: const TextStyle(color: Colors.grey)),
            if (type != 'online')
              Text('Asset: ${widget.bank['file'] ?? '-'}', style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _opening
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_opening ? 'Opening…' : 'Open Paper'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: _opening ? null : _openPaper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PDFScaffold extends StatelessWidget {
  final String title;
  final String filePath;
  const _PDFScaffold({required this.title, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.indigo),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
