import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ResourceViewerScreen extends StatefulWidget {
  final Map<String, dynamic> resource;

  const ResourceViewerScreen({super.key, required this.resource});

  @override
  State<ResourceViewerScreen> createState() => _ResourceViewerScreenState();
}

class _ResourceViewerScreenState extends State<ResourceViewerScreen> {
  @override
  void initState() {
    super.initState();
    _trackView();
  }

  Future<void> _trackView() async {
    await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.resource['id'])
        .update({
      'viewCount': FieldValue.increment(1),
      'lastAccessedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource['title']),
      ),
      body: PDFView(
        filePath: widget.resource['fileUrl'],
        enableSwipe: true,
        swipeHorizontal: false,
      ),
    );
  }
}