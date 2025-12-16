import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:campus_buddy/core/services/storage_service.dart';

/// Internal test screen for validating Firebase Storage uploads.
class StorageTestScreen extends StatefulWidget {
  const StorageTestScreen({super.key});

  @override
  State<StorageTestScreen> createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  final StorageService storage = StorageService();

  String status = "No uploads yet";
  String? downloadUrl;

  /// Picks a file from device storage and uploads it to Firebase Storage.
  /// Note: FilePicker does not work on iOS simulators.
  Future<void> pickAndUpload() async {
    print("[StorageTest] pickAndUpload() called");

    final result = await FilePicker.platform.pickFiles();
    print("[StorageTest] FilePicker result: ${result != null}");

    if (result == null || result.files.single.path == null) {
      print("[StorageTest] No file selected");
      return;
    }

    final file = File(result.files.single.path!);
    print("[StorageTest] Selected file: ${file.path}");

    setState(() => status = "Uploading...");

    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";
    final path = "test_uploads/$fileName";

    final url = await storage.uploadFile(file: file, path: path);

    setState(() {
      if (url != null) {
        status = "Upload successful";
        downloadUrl = url;
      } else {
        status = "Upload failed";
      }
    });
  }

  /// Creates a temporary dummy text file and uploads it.
  /// Useful for iOS simulator testing where FilePicker is not supported.
  Future<void> uploadDummyFile() async {
    print("[StorageTest] Dummy upload started");

    final tempDir = Directory.systemTemp;
    final dummyFile = File("${tempDir.path}/dummy_upload.txt");
    await dummyFile.writeAsString("Simulator test file");

    print("[StorageTest] Dummy file: ${dummyFile.path}");

    setState(() => status = "Uploading dummy file...");

    try {
      final path =
          "test_uploads/simulator_test_${DateTime.now().millisecondsSinceEpoch}.txt";

      final url = await storage.uploadFile(file: dummyFile, path: path);

      if (url != null) {
        print("[StorageTest] Dummy upload successful: $url");
        setState(() {
          status = "Dummy upload successful";
          downloadUrl = url;
        });
      } else {
        print("[StorageTest] Dummy upload returned null URL");
        setState(() => status = "Dummy upload failed");
      }
    } catch (e) {
      print("[StorageTest] Dummy upload exception: $e");
      setState(() => status = "Dummy upload failed");
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
