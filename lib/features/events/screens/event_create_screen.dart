import 'package:flutter/material.dart';
import 'event_details_screen.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _capacity = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _tags = ["Robotics", "Workshop", "Campus", "AI", "Career"];
  final Set<String> _selectedTags = {};

  String? _bannerName; // UI only (fake upload)

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate ?? now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _fakeUploadBanner() {
    setState(() => _bannerName = "event_banner.png");
  }

  String _formatDate(DateTime? d) {
    if (d == null) return "Select date";
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return "Select time";
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  bool _isEndTimeValid() {
    if (_startTime == null || _endTime == null) return true;

    final s = _startTime!.hour * 60 + _startTime!.minute;
    final e = _endTime!.hour * 60 + _endTime!.minute;

    return e > s;
  }

  void _createEventUIOnly() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please choose date, start time, and end time."),
        ),
      );
      return;
    }

    if (!_isEndTimeValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End time must be after start time."),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Create Event clicked (UI only). Waiting for backend."),
      ),
    );

    // OPTIONAL: go to details screen after creating (UI only)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EventDetailsScreen(eventId: "ui-only-temp-id"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner (UI only)
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _bannerName == null
                        ? "No banner selected"
                        : "Selected: $_bannerName",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _fakeUploadBanner,
                icon: const Icon(Icons.upload),
                label: const Text("Upload banner (UI only)"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: "Event Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Title is required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Location is required"
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? "Description must be at least 10 characters"
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacity",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Capacity is required";
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date & Time pickers
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: Text(_formatDate(_selectedDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const Divider(height: 1),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text("Start: ${_formatTime(_startTime)}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickStartTime,
              ),
              const Divider(height: 1),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text("End: ${_formatTime(_endTime)}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickEndTime,
              ),
              const SizedBox(height: 16),

              // Tags
              Text("Tags", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((t) {
                  final selected = _selectedTags.contains(t);
                  return FilterChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedTags.add(t);
                        } else {
                          _selectedTags.remove(t);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _createEventUIOnly,
                icon: const Icon(Icons.add),
                label: const Text("Create Event (UI only)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
