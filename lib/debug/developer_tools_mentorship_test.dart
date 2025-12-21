import 'package:flutter/material.dart';

import '../features/mentorship/services/mentor_service.dart';
import '../features/mentorship/services/mentorship_matching_service.dart';
import '../features/mentorship/services/mentorship_chat_service.dart';
import '../features/mentorship/services/study_group_service.dart';

class DeveloperToolsMentorshipTest extends StatefulWidget {
  const DeveloperToolsMentorshipTest({super.key});

  @override
  State<DeveloperToolsMentorshipTest> createState() =>
      _DeveloperToolsMentorshipTestState();
}

class _DeveloperToolsMentorshipTestState
    extends State<DeveloperToolsMentorshipTest> {
  final _mentorIdCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController(text: 'Computer Engineering');
  final _groupTitleCtrl = TextEditingController(text: 'Algorithms Study Group');
  final _messageCtrl = TextEditingController(text: 'Hello from dev tools');

  final _mentorService = MentorService();
  final _matchingService = MentorshipMatchingService();
  final _chatService = MentorshipChatService();
  final _groupService = StudyGroupService();

  String? _lastRequestId;
  String? _lastSessionId;
  String? _lastGroupId;

  @override
  void dispose() {
    _mentorIdCtrl.dispose();
    _studentIdCtrl.dispose();
    _departmentCtrl.dispose();
    _groupTitleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentorship Dev Tools')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section('IDs'),
          _textField(_mentorIdCtrl, 'Mentor UID'),
          _textField(_studentIdCtrl, 'Student UID'),

          _section('Mentor Profile'),
          _btn('Upsert mentor profile', _upsertMentor),
          _btn('Activate mentor', () => _setMentorActive(true)),
          _btn('Deactivate mentor', () => _setMentorActive(false)),

          _section('Mentorship Requests'),
          _btn('Send request (student → mentor)', _sendRequest),
          _btn('Accept last request (mentor)', _acceptRequest),
          _btn('Reject last request (mentor)', _rejectRequest),

          _section('Sessions'),
          _btn('Create session (mentor)', _createSession),

          _section('Chat'),
          _btn('Send message', _sendChatMessage),

          _section('Study Groups'),
          _textField(_groupTitleCtrl, 'Group title'),
          _btn('Create group', _createGroup),
          _btn('Join group (student)', _joinGroup),
          _btn('Leave group (student)', _leaveGroup),

          const SizedBox(height: 16),
          _debugInfo(),
        ],
      ),
    );
  }

  // ================= guards =================

  bool _requireMentor() {
    if (_mentorIdCtrl.text.trim().isEmpty) {
      _toast('Mentor UID is required');
      return false;
    }
    return true;
  }

  bool _requireStudent() {
    if (_studentIdCtrl.text.trim().isEmpty) {
      _toast('Student UID is required');
      return false;
    }
    return true;
  }

  bool _requireMentorAndStudent() {
    return _requireMentor() && _requireStudent();
  }

  // ================= actions =================

  Future<void> _upsertMentor() async {
    if (!_requireMentor()) return;

    await _mentorService.upsertMentorProfile(
      mentorId: _mentorIdCtrl.text.trim(),
      userId: _mentorIdCtrl.text.trim(),
      name: 'Test Mentor',
      department: _departmentCtrl.text.trim(),
      expertise: const ['algorithms', 'data structures'],
    );

    _toast('Mentor profile upserted');
  }

  Future<void> _setMentorActive(bool active) async {
    if (!_requireMentor()) return;

    await _mentorService.setMentorActive(
      _mentorIdCtrl.text.trim(),
      active,
    );

    _toast('Mentor active = $active');
  }

  Future<void> _sendRequest() async {
    if (!_requireMentorAndStudent()) return;

    final id = await _matchingService.sendMentorshipRequest(
      studentId: _studentIdCtrl.text.trim(),
      mentorId: _mentorIdCtrl.text.trim(),
      message: 'Request from dev tools',
    );

    setState(() => _lastRequestId = id);
    _toast('Request sent');
  }

  Future<void> _acceptRequest() async {
    if (!_requireMentor()) return;
    if (_lastRequestId == null) {
      _toast('No request to accept');
      return;
    }

    await _matchingService.acceptRequest(
      requestId: _lastRequestId!,
      mentorId: _mentorIdCtrl.text.trim(),
    );

    _toast('Request accepted');
  }

  Future<void> _rejectRequest() async {
    if (!_requireMentor()) return;
    if (_lastRequestId == null) {
      _toast('No request to reject');
      return;
    }

    await _matchingService.rejectRequest(
      requestId: _lastRequestId!,
      mentorId: _mentorIdCtrl.text.trim(),
    );

    _toast('Request rejected');
  }

  Future<void> _createSession() async {
    if (!_requireMentorAndStudent()) return;

    final id = await _matchingService.createSession(
      mentorId: _mentorIdCtrl.text.trim(),
      studentId: _studentIdCtrl.text.trim(),
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
    );

    setState(() => _lastSessionId = id);
    _toast('Session created');
  }

  Future<void> _sendChatMessage() async {
    if (!_requireMentorAndStudent()) return;

    final chatId = _chatService.buildChatId(
      mentorId: _mentorIdCtrl.text.trim(),
      studentId: _studentIdCtrl.text.trim(),
    );

    await _chatService.ensureChatExists(
      chatId: chatId,
      mentorId: _mentorIdCtrl.text.trim(),
      studentId: _studentIdCtrl.text.trim(),
    );

    await _chatService.sendMessage(
      chatId: chatId,
      senderId: _mentorIdCtrl.text.trim(),
      text: _messageCtrl.text.trim(),
    );

    _toast('Message sent');
  }

  Future<void> _createGroup() async {
    if (!_requireMentor()) return;

    final id = await _groupService.createGroup(
      title: _groupTitleCtrl.text.trim(),
      createdBy: _mentorIdCtrl.text.trim(),
      tags: const ['cs', 'exam'],
    );

    setState(() => _lastGroupId = id);
    _toast('Group created');
  }

  Future<void> _joinGroup() async {
    if (!_requireStudent()) return;
    if (_lastGroupId == null) {
      _toast('No group created');
      return;
    }

    await _groupService.joinGroup(
      groupId: _lastGroupId!,
      uid: _studentIdCtrl.text.trim(),
    );

    _toast('Student joined group');
  }

  Future<void> _leaveGroup() async {
    if (!_requireStudent()) return;
    if (_lastGroupId == null) {
      _toast('No group to leave');
      return;
    }

    await _groupService.leaveGroup(
      groupId: _lastGroupId!,
      uid: _studentIdCtrl.text.trim(),
    );

    _toast('Student left group');
  }

  // ================= UI helpers =================

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _btn(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _debugInfo() {
    return Card(
      child: ListTile(
        title: const Text('Debug State'),
        subtitle: Text(
          'lastRequestId: $_lastRequestId\n'
              'lastSessionId: $_lastSessionId\n'
              'lastGroupId: $_lastGroupId',
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
