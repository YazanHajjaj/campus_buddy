import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';
import 'package:campus_buddy/features/resources/services/resource_service_impl.dart';
import 'package:campus_buddy/features/resources/services/resource_service.dart';

/// Developer-only screen to verify ResourceService behavior.
/// Used during backend validation, not part of production UI.
class ResourceBackendTestScreen extends StatefulWidget {
  const ResourceBackendTestScreen({super.key});

  @override
  State<ResourceBackendTestScreen> createState() =>
      _ResourceBackendTestScreenState();
}

class _ResourceBackendTestScreenState extends State<ResourceBackendTestScreen> {
  late final ResourceService resourceService;

  String _statusKey = 'resourceTest.waiting';
  String? _details;

  @override
  void initState() {
    super.initState();
    resourceService = FirestoreResourceService();
    _runTest();
  }

  Future<void> _runTest() async {
    try {
      setState(() {
        _statusKey = 'resourceTest.creating';
        _details = null;
      });

      final testResource = await resourceService.createResource(
        title: 'Backend Test Resource',
        description: 'Backend write test.',
        storagePath: 'resources/test/file',
        fileUrl: 'https://example.com/fake.pdf',
        uploaderUserId: 'testUser123',
        uploaderDisplayName: 'Test User',
        tags: ['test', 'backend'],
        sizeInBytes: 12345,
        mimeType: 'application/pdf',
        isPublic: true,
      );

      setState(() {
        _statusKey = 'resourceTest.success';
        _details = testResource.id;
      });

      // Developer log
      print(
        '[ResourceBackendTest] Resource created: ${testResource.id}',
      );
    } catch (e, stack) {
      setState(() {
        _statusKey = 'resourceTest.error';
        _details = e.toString();
      });

      print('[ResourceBackendTest] Error: $e');
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('resourceTest.title')),
      ),
      body: Center(
        child: Text(
          _buildStatusText(t),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  String _buildStatusText(AppLocalizations t) {
    final base = t.t(_statusKey);
    if (_details == null) return base;
    return '$base\n$_details';
  }
}