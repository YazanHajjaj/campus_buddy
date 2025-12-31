import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/storage_service.dart';

/// Developer-only screen to validate Firebase Storage uploads.
/// Used for real device and simulator testing.
class StorageTestScreen extends StatefulWidget {
  const StorageTestScreen({super.key});

  @override
  State<StorageTestScreen> createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  final StorageService storage = StorageService();

  String status = 'idle';
  String? downloadUrl;

  /// Picks a file from device storage and uploads it.
  /// FilePicker does not work on iOS simulators.
  Future<void> pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    setState(() => status = 'uploading');

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
    final path = 'test_uploads/$fileName';

    final url = await storage.uploadFile(file: file, path: path);

    setState(() {
      if (url != null) {
        status = 'success';
        downloadUrl = url;
      } else {
        status = 'failed';
      }
    });
  }

  /// Uploads a generated text file.
  /// Used for simulator testing where file picker is unavailable.
  Future<void> uploadDummyFile() async {
    final tempDir = Directory.systemTemp;
    final dummyFile = File('${tempDir.path}/dummy_upload.txt');
    await dummyFile.writeAsString('Simulator test file');

    setState(() => status = 'uploading');

    final path =
        'test_uploads/simulator_${DateTime.now().millisecondsSinceEpoch}.txt';
    final url = await storage.uploadFile(file: dummyFile, path: path);

    setState(() {
      if (url != null) {
        status = 'success';
        downloadUrl = url;
      } else {
        status = 'failed';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('storage.testTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: pickAndUpload,
              child: Text(t.t('storage.pickAndUpload')),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: uploadDummyFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
              child: Text(t.t('storage.uploadDummy')),
            ),
            const SizedBox(height: 25),
            Text(
              _statusLabel(status, t),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (downloadUrl != null)
              SelectableText(
                '${t.t('storage.downloadUrl')}:\n$downloadUrl',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String value, AppLocalizations t) {
    switch (value) {
      case 'uploading':
        return t.t('storage.uploading');
      case 'success':
        return t.t('storage.uploadSuccess');
      case 'failed':
        return t.t('storage.uploadFailed');
      default:
        return t.t('storage.idle');
    }
  }
}