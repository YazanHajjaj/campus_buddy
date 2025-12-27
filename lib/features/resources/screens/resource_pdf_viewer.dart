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

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}