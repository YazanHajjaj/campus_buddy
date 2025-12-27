import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResourcePdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const ResourcePdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ResourcePdfViewerScreen> createState() =>
      _ResourcePdfViewerScreenState();
}

class _ResourcePdfViewerScreenState extends State<ResourcePdfViewerScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // ───── APP BAR ─────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Stack(
        children: [
          // PDF VIEW
          WebViewWidget(controller: _controller),

          // LOADING OVERLAY
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}