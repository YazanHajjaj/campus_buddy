import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_localizations.dart';
import '../services/study_group_service.dart';

class CreateStudyGroupScreen extends StatefulWidget {
  const CreateStudyGroupScreen({super.key});

  @override
  State<CreateStudyGroupScreen> createState() =>
      _CreateStudyGroupScreenState();
}

class _CreateStudyGroupScreenState extends State<CreateStudyGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = StudyGroupService();

  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await _service.createGroup(
        title: _titleController.text.trim(),
        course: _courseController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: uid,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('studyGroups.createTitle'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _SectionCard(
              child: Column(
                children: [
                  _InputField(
                    controller: _titleController,
                    label: t.t('studyGroups.fieldTitle'),
                    validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? t.t('common.required')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _courseController,
                    label: t.t('studyGroups.fieldCourse'),
                    validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? t.t('common.required')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _descriptionController,
                    label: t.t('studyGroups.fieldDescription'),
                    maxLines: 3,
                    validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? t.t('common.required')
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  t.t('studyGroups.createAction'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── UI HELPERS ───────────────── */

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}