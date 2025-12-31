import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _trackView();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.resource['fileUrl']));
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

  void _shareResource() {
    final box = context.findRenderObject() as RenderBox;
    final title = widget.resource['title'] ?? 'Resource';
    final url = widget.resource['fileUrl'];

    Share.share(
      '$title\n$url',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.resource['title'] ?? 'Resource';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResource,
          ),
        ],
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}