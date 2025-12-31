import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../features/notifications/helpers/reminder_helper.dart';
import '../../../features/notifications/services/local_notification_service.dart';
import '../models/study_group_session.dart';
import '../services/study_group_session_service.dart';

class CreateStudyGroupSessionScreen extends StatefulWidget {
  final String groupId;

  /// TEMP: injected later via provider
  final LocalNotificationService? notificationService;

  const CreateStudyGroupSessionScreen({
    super.key,
    required this.groupId,
    this.notificationService,
  });

  @override
  State<CreateStudyGroupSessionScreen> createState() =>
      _CreateStudyGroupSessionScreenState();
}

class _CreateStudyGroupSessionScreenState
    extends State<CreateStudyGroupSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = StudyGroupSessionService();

  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;
    if (!_formKey.currentState!.validate() || _date == null) return;

    setState(() => _saving = true);

    try {
      // 1️ Create session in Firestore
      final docRef = await _service.createSession(
        groupId: widget.groupId,
        title: _titleCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        date: Timestamp.fromDate(_date!),
        startTime: _startCtrl.text.trim(),
        endTime: _endCtrl.text.trim(),
        createdBy: uid,
      );
      debugPrint('SESSION CREATED: ${docRef.id}');
      // 2⃣ Build session object (for reminder logic)
      final session = StudyGroupSession(
        id: docRef.id,
        groupId: widget.groupId,
        title: _titleCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        date: Timestamp.fromDate(_date!),
        startTime: _startCtrl.text.trim(),
        endTime: _endCtrl.text.trim(),
        createdBy: uid,
        createdAt: Timestamp.now(),
      );

      // 3️⃣ Schedule reminder (SAFE – no plugin required)
      if (widget.notificationService != null) {
        await widget.notificationService!.showNotification(
          title: ReminderHelper.sessionReminderTitle(
            groupTitle: t.t('studyGroups.title'),
          ),
          body: ReminderHelper.sessionReminderBody(
            session: session,
          ),
          payload: ReminderHelper.sessionPayload(
            groupId: widget.groupId,
            sessionId: session.id,
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('studyGroups.reminderSet')),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('CREATE SESSION ERROR: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final dateLabel = _date == null
        ? t.t('studyGroups.pickDate')
        : DateFormat('EEE, MMM d').format(_date!);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('studyGroups.createSession'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Input(
              controller: _titleCtrl,
              label: t.t('studyGroups.sessionTitle'),
            ),
            const SizedBox(height: 12),
            _Input(
              controller: _locationCtrl,
              label: t.t('studyGroups.location'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Input(
                    controller: _startCtrl,
                    label: t.t('studyGroups.startTime'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Input(
                    controller: _endCtrl,
                    label: t.t('studyGroups.endTime'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(dateLabel),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  t.t('common.save'),
                  style:
                  const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────── INPUT ───────── */

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _Input({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (v) =>
      v == null || v.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}