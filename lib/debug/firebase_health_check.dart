import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_buddy/features/storage/storage_test_screen.dart';

class FirebaseHealthCheckScreen extends StatefulWidget {
  const FirebaseHealthCheckScreen({super.key});

  @override
  State<FirebaseHealthCheckScreen> createState() =>
      _FirebaseHealthCheckScreenState();
}

class _FirebaseHealthCheckScreenState extends State<FirebaseHealthCheckScreen> {
  String coreStatus = "Pending";
  String authStatus = "Pending";
  String firestoreWriteStatus = "Pending";
  String firestoreReadStatus = "Pending";

  Map<String, dynamic>? testDocument;

  Future<void> runChecks() async {
    setState(() {
      coreStatus = "Checking...";
      authStatus = "Pending";
      firestoreWriteStatus = "Pending";
      firestoreReadStatus = "Pending";
      testDocument = null;
    });

    // -------------------------------------------------------------
    // 1. Firebase Core Check
    // -------------------------------------------------------------
    try {
      final apps = Firebase.apps;
      if (apps.isNotEmpty) {
        coreStatus = "OK";
      } else {
        coreStatus = "FAILED";
      }
    } catch (e) {
      coreStatus = "FAILED: $e";
    }

    // -------------------------------------------------------------
    // 2. Firebase Auth Check (Anonymous Login)
    // -------------------------------------------------------------
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        authStatus = "OK (UID: ${user.uid})";
      } else {
        authStatus = "FAILED";
      }
    } catch (e) {
      authStatus = "FAILED: $e";
    }

    // -------------------------------------------------------------
    // 3. Firestore Write Check
    // -------------------------------------------------------------
    try {
      final testRef =
      FirebaseFirestore.instance.collection("health_check_test");
      await testRef.doc("test_doc").set({
        "timestamp": DateTime.now().toIso8601String(),
        "status": "write_success",
      });

      firestoreWriteStatus = "OK";
    } catch (e) {
      firestoreWriteStatus = "FAILED: $e";
    }

    // -------------------------------------------------------------
    // 4. Firestore Read Check
    // -------------------------------------------------------------
    try {
      final testRef =
      FirebaseFirestore.instance.collection("health_check_test");
      final snapshot = await testRef.doc("test_doc").get();

      if (snapshot.exists) {
        firestoreReadStatus = "OK";
        testDocument = snapshot.data();
      } else {
        firestoreReadStatus = "FAILED (No document found)";
      }
    } catch (e) {
      firestoreReadStatus = "FAILED: $e";
    }

    setState(() {});
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Health Check")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Firebase System Status",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildStatusTile("Firebase Core", coreStatus),
          _buildStatusTile("Auth (Anonymous Sign-In)", authStatus),
          _buildStatusTile("Firestore Write", firestoreWriteStatus),
          _buildStatusTile("Firestore Read", firestoreReadStatus),

          const SizedBox(height: 20),

          if (testDocument != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Read Document:\n${testDocument.toString()}",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

          const SizedBox(height: 40),

          // Existing button
          FilledButton(
            onPressed: runChecks,
            child: const Text("Run Health Check"),
          ),

          const SizedBox(height: 20),

          // Button to open Storage Test Screen
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StorageTestScreen(),
                ),
              );
            },
            child: const Text("Open Storage Test Screen"),
          ),
        ],
      ),
    );
  }

  // UI Helper
  Widget _buildStatusTile(String title, String status) {
    final ok = status.startsWith("OK");
    final fail = status.startsWith("FAILED");

    Color color = Colors.grey;
    if (ok) color = Colors.green;
    if (fail) color = Colors.red;

    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.error,
        color: color,
      ),
      title: Text(title),
      subtitle: Text(status),
    );
  }
}
