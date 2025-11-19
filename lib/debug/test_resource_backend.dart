import 'package:flutter/material.dart';

import 'package:campus_buddy/features/resources/services/resource_service_impl.dart';
import 'package:campus_buddy/features/resources/services/resource_service.dart';

/// Simple screen used to verify ResourceService behavior during development.
class ResourceBackendTestScreen extends StatefulWidget {
  const ResourceBackendTestScreen({super.key});

  @override
  State<ResourceBackendTestScreen> createState() =>
      _ResourceBackendTestScreenState();
}

class _ResourceBackendTestScreenState extends State<ResourceBackendTestScreen> {
  late final ResourceService resourceService;
  String status = "Waiting...";

  @override
  void initState() {
    super.initState();
    resourceService = FirestoreResourceService();
    _runTest();
  }

  Future<void> _runTest() async {
    try {
      setState(() => status = "Creating test resource...");

      final testResource = await resourceService.createResource(
        title: "Backend Test Resource",
        description: "Backend write test.",
        storagePath: "resources/test/file",
        fileUrl: "https://example.com/fake.pdf",
        uploaderUserId: "testUser123",
        uploaderDisplayName: "Test User",
        tags: ["test", "backend"],
        sizeInBytes: 12345,
        mimeType: "application/pdf",
        isPublic: true,
      );

      setState(() => status = "Success\nCreated ID: ${testResource.id}");

      // Console logging for developers
      print("[Resource Test] Successfully created resource: ${testResource.id}");
    } catch (e, stack) {
      setState(() => status = "Error\n$e");

      print("[Resource Test] Error: $e");
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resource Backend Test")),
      body: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
