import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/mentorship_request.dart';
import '../services/mentorship_matching_service.dart';

class MyMentorshipRequestsScreen extends StatefulWidget {
  const MyMentorshipRequestsScreen({super.key});

  @override
  State<MyMentorshipRequestsScreen> createState() =>
      _MyMentorshipRequestsScreenState();
}

class _MyMentorshipRequestsScreenState
    extends State<MyMentorshipRequestsScreen> {
  final _auth = FirebaseAuth.instance;
  final _service = MentorshipMatchingService();

  static const _primaryBlue = Color(0xFF2446C8);

  String? get _studentId => _auth.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final studentId = _studentId;

    if (studentId == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // ✅ CONSISTENT BLUE APP BAR
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'My Mentorship Requests',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: StreamBuilder<List<MentorshipRequest>>(
        stream: _service.streamMyRequestsForStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load requests'),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'You haven’t sent any mentorship requests yet',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _StudentRequestCard(
                request: requests[index],
                service: _service,
                studentId: studentId,
              );
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── REQUEST CARD ───────────────── */

class _StudentRequestCard extends StatefulWidget {
  final MentorshipRequest request;
  final MentorshipMatchingService service;
  final String studentId;

  const _StudentRequestCard({
    required this.request,
    required this.service,
    required this.studentId,
  });

  @override
  State<_StudentRequestCard> createState() => _StudentRequestCardState();
}

class _StudentRequestCardState extends State<_StudentRequestCard> {
  static const _primaryBlue = Color(0xFF2446C8);
  bool _loading = false;

  Future<void> _cancel() async {
    setState(() => _loading = true);
    try {
      await widget.service.cancelRequest(
        requestId: widget.request.id,
        studentId: widget.studentId,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel request')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER ───
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _primaryBlue.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person_outline,
                  color: _primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mentor ID: ${r.mentorId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              _StatusBadge(status: r.status),
            ],
          ),

          // ─── MESSAGE ───
          if (r.message != null && r.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              r.message!.trim(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ],

          // ─── ACTION ───
          if (r.status == MentorshipRequestStatus.pending) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : _cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  'Cancel Request',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ───────────────── STATUS BADGE ───────────────── */

class _StatusBadge extends StatelessWidget {
  final MentorshipRequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;

    switch (status) {
      case MentorshipRequestStatus.accepted:
        color = Colors.green;
        label = 'Accepted';
        break;
      case MentorshipRequestStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case MentorshipRequestStatus.canceled:
        color = Colors.grey;
        label = 'Canceled';
        break;
      case MentorshipRequestStatus.pending:
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}