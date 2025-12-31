import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/localization/app_localizations.dart';

import '../models/mentor_profile.dart';
import '../services/mentorship_matching_service.dart';

import 'mentorship_request_sent_screen.dart';
import 'edit_mentor_profile_screen.dart';

/// Displays a single mentor profile
/// - Students can REQUEST mentorship
/// - Mentors can edit ONLY from mentor side (allowEdit = true)
class MentorProfileScreen extends StatefulWidget {
  /// mentor_profiles/{mentorId} document id
  final String mentorId;

  /// True only when opened from Mentor side ("My Profile")
  final bool allowEdit;

  const MentorProfileScreen({
    super.key,
    required this.mentorId,
    this.allowEdit = false,
  });

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _matchingService = MentorshipMatchingService();

  bool _sending = false;

  Stream<MentorProfile?> _streamMentor() {
    return FirebaseFirestore.instance
        .collection('mentor_profiles')
        .doc(widget.mentorId)
        .snapshots()
        .map((doc) => doc.exists ? MentorProfile.fromDoc(doc) : null);
  }

  /// MAIN FLOW — Send mentorship request
  Future<void> _sendRequest(MentorProfile mentor) async {
    final t = AppLocalizations.of(context);
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _sending = true);

    try {
      await _matchingService.sendMentorshipRequest(
        studentId: user.uid,
        mentorId: widget.mentorId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MentorshipRequestSentScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('mentorship.title'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<MentorProfile?>(
        stream: _streamMentor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mentor = snapshot.data;
          if (mentor == null) {
            return Center(child: Text(t.t('error.generic')));
          }

          final bool isOwner =
              currentUid != null && currentUid == mentor.userId;
          final bool showEdit = widget.allowEdit && isOwner;

          final bool isFull = mentor.isFull;
          final bool hasRatings = mentor.ratingCount > 0;

          final statusColor = isFull ? colors.error : colors.primary;
          final statusBg = statusColor.withOpacity(0.12);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── HEADER ─────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: colors.primary.withOpacity(0.12),
                      backgroundImage: mentor.photoUrl != null
                          ? NetworkImage(mentor.photoUrl!)
                          : null,
                      child: mentor.photoUrl == null
                          ? Icon(
                        Icons.person,
                        size: 42,
                        color: colors.primary,
                      )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mentor.department ?? '—',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ───────── EDIT BUTTON (MENTOR ONLY) ─────────
                if (showEdit) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(
                        t.t('profile.edit'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const EditMentorProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // ───────── RATINGS ─────────
                hasRatings
                    ? Row(
                  children: [
                    const Icon(Icons.star,
                        size: 18, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      mentor.ratingAvg.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${mentor.ratingCount})',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                )
                    : Text(
                  t.t('mentorship.noRatings'),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.black54),
                ),

                const SizedBox(height: 18),

                // ───────── STATUS ─────────
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isFull ? Icons.block : Icons.check_circle,
                        size: 18,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFull
                            ? t.t('mentorship.fullyBooked')
                            : t.t('mentorship.available'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ───────── BIO ─────────
                if (mentor.bio != null && mentor.bio!.trim().isNotEmpty) ...[
                  Text(
                    t.t('profile.title'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mentor.bio!.trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                ],

                // ───────── REQUEST BUTTON ─────────
                if (!showEdit)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (_sending || isFull)
                          ? null
                          : () => _sendRequest(mentor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _sending
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        isFull
                            ? t.t('events.capacityFull')
                            : t.t('mentorship.request'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}