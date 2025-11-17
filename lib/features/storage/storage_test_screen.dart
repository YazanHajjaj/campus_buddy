import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:campus_buddy/core/services/storage_service.dart';

class StorageTestScreen extends StatefulWidget {
  const StorageTestScreen({super.key});

  @override
  State<StorageTestScreen> createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  String status = "No uploads yet";
  String? downloadUrl;

  final StorageService storage = StorageService();

  // -------------------------------------------------------------
  // PICK FILE (for real devices — does NOT work on iOS simulator)
  // -------------------------------------------------------------
  Future<void> pickAndUpload() async {
    print("🟢 [UI] pickAndUpload() called");

    final result = await FilePicker.platform.pickFiles();
    print("📎 [UI] FilePicker result: ${result != null}");

    if (result == null || result.files.single.path == null) {
      print("⚠️ [UI] No file selected");
      return;
    }

    final file = File(result.files.single.path!);
    print("📎 [UI] Selected file path: ${file.path}");

    setState(() => status = "Uploading...");

    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";
    final path = "test_uploads/$fileName";
    print("📝 [UI] Uploading real file to: $path");

    final url = await storage.uploadFile(file: file, path: path);

    setState(() {
      if (url != null) {
        status = "Upload successful!";
        downloadUrl = url;
      } else {
        status = "Upload failed!";
      }
    });
  }

  // -------------------------------------------------------------
  // DUMMY UPLOAD (works on iOS SIMULATOR)
  // -------------------------------------------------------------
  Future<void> uploadDummyFile() async {
    print("🟢 [UI] Dummy upload started");

    final tempDir = Directory.systemTemp;
    final dummyFile = File("${tempDir.path}/dummy_upload.txt");
    await dummyFile.writeAsString("Hello from iOS Simulator test!");

    print("📄 [UI] Dummy file created at: ${dummyFile.path}");

    setState(() => status = "Uploading dummy file...");

    try {
      final path =
          "test_uploads/simulator_test_${DateTime.now().millisecondsSinceEpoch}.txt";
      print("📝 [UI] Uploading dummy to: $path");

      final url = await storage.uploadFile(file: dummyFile, path: path);

      if (url != null) {
        print("✅ [UI] Dummy upload successful: $url");
        setState(() {
          status = "Dummy upload successful!";
          downloadUrl = url;
        });
      } else {
        print("💥 [UI] Dummy upload returned null URL");
        setState(() => status = "Dummy upload failed!");
      }
    } catch (e) {
      print("🔥 [UI] Dummy upload EXCEPTION: $e");
      setState(() => status = "Dummy upload failed!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Storage Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: pickAndUpload,
              child: const Text("Pick File & Upload (Real Device Only)"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: uploadDummyFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text("Upload Dummy File (Simulator Test)"),
            ),
            const SizedBox(height: 25),
            Text(
              status,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (downloadUrl != null)
              SelectableText(
                "Download URL:\n$downloadUrl",
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
