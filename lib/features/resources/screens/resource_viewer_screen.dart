import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ResourceViewerScreen extends StatefulWidget {
  final Map<String, dynamic> resource;

  const ResourceViewerScreen({
    super.key,
    required this.resource,
  });

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
    final title = widget.resource['title'] ?? 'Resource';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // ───── APP BAR ─────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // ───── PDF VIEW ─────
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: PDFView(
          filePath: widget.resource['fileUrl'],
          enableSwipe: true,
          swipeHorizontal: false,
        ),
      ),
    );
  }
}