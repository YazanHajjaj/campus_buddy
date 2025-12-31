import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_ui.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  Map<String, bool> checklist = {
    'profileCompleted': false,
    'browsedResources': false,
    'bookmarkedResource': false,
    'joinedStudyGroup': false,
    'sentMentorshipRequest': false,
  };

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc =
    await _firestore.collection('users').doc(uid).get();

    final data = doc.data();
    final remote =
    data?['onboardingChecklist'] as Map<String, dynamic>?;

    // ✅ SAFE MERGE: defaults + Firestore values
    checklist = {
      'profileCompleted': remote?['profileCompleted'] ?? false,
      'browsedResources': remote?['browsedResources'] ?? false,
      'bookmarkedResource': remote?['bookmarkedResource'] ?? false,
      'joinedStudyGroup': remote?['joinedStudyGroup'] ?? false,
      'sentMentorshipRequest': remote?['sentMentorshipRequest'] ?? false,
    };

    setState(() => isLoading = false);
  }

  int get completedCount =>
      checklist.values.where((v) => v).length;

  double get progress =>
      checklist.isEmpty ? 0 : completedCount / checklist.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUI.background,
      appBar: AppBar(
        title: const Text('Getting Started'),
        backgroundColor: AppUI.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(),
            const SizedBox(height: 16),
            _buildChecklistCard(),
          ],
        ),
      ),
    );
  }

  /* ───────────────── PROGRESS ───────────────── */

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppUI.cardRadius,
        boxShadow: AppUI.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Onboarding Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            color: AppUI.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount of ${checklist.length} completed',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /* ───────────────── CHECKLIST ───────────────── */

  Widget _buildChecklistCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppUI.cardRadius,
        boxShadow: AppUI.cardShadow,
      ),
      child: Column(
        children: [
          _checkItem(
            'Complete your profile',
            checklist['profileCompleted'] ?? false,
          ),
          _divider(),
          _checkItem(
            'Browse campus resources',
            checklist['browsedResources'] ?? false,
          ),
          _divider(),
          _checkItem(
            'Bookmark a resource',
            checklist['bookmarkedResource'] ?? false,
          ),
          _divider(),
          _checkItem(
            'Join a study group',
            checklist['joinedStudyGroup'] ?? false,
          ),
          _divider(),
          _checkItem(
            'Request a mentor',
            checklist['sentMentorshipRequest'] ?? false,
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String title, bool completed) {
    return ListTile(
      leading: Icon(
        completed
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
        color: completed ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          decoration:
          completed ? TextDecoration.lineThrough : null,
          color:
          completed ? Colors.grey : Colors.black87,
        ),
      ),
      trailing: completed
          ? const Text(
        'Done',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      )
          : null,
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}