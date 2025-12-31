import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/localization/app_localizations.dart';
import 'storage_test_screen.dart';

/// Developer-only screen to validate Firebase setup.
/// Used to verify core, auth, and Firestore connectivity.
class FirebaseHealthCheckScreen extends StatefulWidget {
  const FirebaseHealthCheckScreen({super.key});

  @override
  State<FirebaseHealthCheckScreen> createState() =>
      _FirebaseHealthCheckScreenState();
}

class _FirebaseHealthCheckScreenState extends State<FirebaseHealthCheckScreen> {
  String coreStatus = 'pending';
  String authStatus = 'pending';
  String firestoreWriteStatus = 'pending';
  String firestoreReadStatus = 'pending';

  Map<String, dynamic>? testDocument;

  Future<void> runChecks() async {
    setState(() {
      coreStatus = 'checking';
      authStatus = 'pending';
      firestoreWriteStatus = 'pending';
      firestoreReadStatus = 'pending';
      testDocument = null;
    });

    // Firebase Core
    try {
      final apps = Firebase.apps;
      coreStatus = apps.isNotEmpty ? 'ok' : 'failed';
    } catch (_) {
      coreStatus = 'failed';
    }

    // Auth (anonymous)
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      authStatus = cred.user != null ? 'ok' : 'failed';
    } catch (_) {
      authStatus = 'failed';
    }

    // Firestore write
    try {
      final ref =
      FirebaseFirestore.instance.collection('health_check_test');

      await ref.doc('test_doc').set({
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'write_success',
      });

      firestoreWriteStatus = 'ok';
    } catch (_) {
      firestoreWriteStatus = 'failed';
    }

    // Firestore read
    try {
      final ref =
      FirebaseFirestore.instance.collection('health_check_test');

      final snapshot = await ref.doc('test_doc').get();
      if (snapshot.exists) {
        firestoreReadStatus = 'ok';
        testDocument = snapshot.data();
      } else {
        firestoreReadStatus = 'failed';
      }
    } catch (_) {
      firestoreReadStatus = 'failed';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('firebase.healthCheck')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t.t('firebase.systemStatus'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          _buildStatusTile(
            t.t('firebase.core'),
            coreStatus,
            theme,
            t,
          ),
          _buildStatusTile(
            t.t('firebase.auth'),
            authStatus,
            theme,
            t,
          ),
          _buildStatusTile(
            t.t('firebase.firestoreWrite'),
            firestoreWriteStatus,
            theme,
            t,
          ),
          _buildStatusTile(
            t.t('firebase.firestoreRead'),
            firestoreReadStatus,
            theme,
            t,
          ),

          const SizedBox(height: 20),

          if (testDocument != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${t.t('firebase.readDocument')}:\n'
                      '${testDocument.toString()}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),

          const SizedBox(height: 40),

          FilledButton(
            onPressed: runChecks,
            child: Text(t.t('firebase.runCheck')),
          ),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StorageTestScreen(),
                ),
              );
            },
            child: Text(t.t('firebase.openStorageTest')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(
      String title,
      String status,
      ThemeData theme,
      AppLocalizations t,
      ) {
    final ok = status == 'ok';
    final checking = status == 'checking';

    Color color = theme.colorScheme.outline;
    if (ok) color = Colors.green;
    if (status == 'failed') color = Colors.red;

    String label = t.t('firebase.statusPending');
    if (checking) label = t.t('firebase.statusChecking');
    if (ok) label = t.t('firebase.statusOk');
    if (status == 'failed') label = t.t('firebase.statusFailed');

    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.error,
        color: color,
      ),
      title: Text(title),
      subtitle: Text(label),
    );
  }
}