import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/event.dart';
import '../services/event_firestore_service.dart';
import 'event_details_screen.dart';

class EventCreateScreen extends StatefulWidget {
  final String uid;

  const EventCreateScreen({
    super.key,
    required this.uid,
  });

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventFirestoreService();
  final _imagePicker = ImagePicker();

  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _capacity = TextEditingController();
  final _customTagController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  File? _imageFile;
  bool _submitting = false;

  final List<String> _systemTags = [
    'Workshop',
    'Career',
    'AI',
    'Robotics',
    'Campus',
    'Hackathon',
    'Research',
    'Social',
  ];

  final Set<String> _selectedSystemTags = {};
  final Set<String> _customTags = {};

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _capacity.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  /* ───────────────── IMAGE ───────────────── */

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImage(String eventId) async {
    if (_imageFile == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child('event_images')
        .child('$eventId.jpg');

    await ref.putFile(_imageFile!);
    return ref.getDownloadURL();
  }

  /* ───────────────── DATE & TIME ───────────────── */

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDate: DateTime.now(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEndDateTime() async {
    if (_startDateTime == null) return;

    final date = await showDatePicker(
      context: context,
      firstDate: _startDateTime!,
      lastDate: DateTime(DateTime.now().year + 2),
      initialDate: _startDateTime!,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime!),
    );
    if (time == null) return;

    setState(() {
      _endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  bool _timeValid() =>
      _startDateTime != null &&
          _endDateTime != null &&
          _endDateTime!.isAfter(_startDateTime!);

  /* ───────────────── TAGS ───────────────── */

  void _addCustomTag() {
    final text = _customTagController.text.trim().toLowerCase();
    if (text.isEmpty || text.length > 20 || _customTags.length >= 3) return;

    setState(() {
      _customTags.add(text);
      _customTagController.clear();
    });
  }

  /* ───────────────── CREATE EVENT ───────────────── */

  Future<void> _createEvent() async {
    final t = AppLocalizations.of(context);

    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (!_timeValid()) {
      _toast(t.t('events.invalidTime'));
      return;
    }

    setState(() => _submitting = true);

    try {
      final now = DateTime.now();

      final event = Event(
        id: '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        location: _location.text.trim(),
        date: DateTime(
          _startDateTime!.year,
          _startDateTime!.month,
          _startDateTime!.day,
        ),
        startTime: _startDateTime!,
        endTime: _endDateTime!,
        createdBy: widget.uid,
        isOnline: false,
        imageUrl: null,
        tags: [..._selectedSystemTags, ..._customTags],
        capacity: int.tryParse(_capacity.text.trim()) ?? 0,
        attendeesCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      final eventId = await _eventService.createEvent(event);

      final imageUrl = await _uploadImage(eventId);
      if (imageUrl != null) {
        await _eventService.updateEventImage(
          eventId: eventId,
          imageUrl: imageUrl,
        );
      }

      // 🔔 In-app notification (Firestore)
      await FirebaseFirestore.instance.collection('notifications').add({
        'uid': widget.uid,
        'titleKey': 'events.eventCreated',
        'title': t.t('events.eventCreated'),
        'body': event.title,
        'type': 'event_created',
        'referenceId': eventId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _submitting = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: eventId),
        ),
      );
    } catch (_) {
      _toast(t.t('common.error'));
      if (mounted) setState(() => _submitting = false);
    }
  }

  /* ───────────────── UI ───────────────── */

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(t.t('events.create')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: _imageFile == null
                        ? const Center(child: Icon(Icons.image, size: 48))
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _imageFile!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(t.t('events.addPhoto')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              Column(
                children: [
                  _field(_title, t.t('events.title')),
                  const SizedBox(height: 12),
                  _field(_location, t.t('events.location')),
                  const SizedBox(height: 12),
                  _field(_description, t.t('events.description'), maxLines: 4),
                  const SizedBox(height: 12),
                  _field(
                    _capacity,
                    t.t('events.capacity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              Column(
                children: [
                  _picker(t.t('events.startsAt'), _startDateTime, _pickStartDateTime),
                  const Divider(),
                  _picker(t.t('events.endsAt'), _endDateTime, _pickEndDateTime),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _submitting ? null : _createEvent,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  t.t('events.create'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ───────────────── HELPERS ───────────────── */

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _field(
      TextEditingController c,
      String label, {
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _picker(String label, DateTime? value, VoidCallback onTap) {
    return ListTile(
      title: Text(
        value == null
            ? label
            : '$label — ${value.day}/${value.month}/${value.year} '
            '${value.hour.toString().padLeft(2, '0')}:'
            '${value.minute.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}