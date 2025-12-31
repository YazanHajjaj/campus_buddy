import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';
import '../models/mentor_profile.dart';
import 'mentor_profile_screen.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  /// Stream mentors and sort by:
  /// 1️⃣ availability
  /// 2️⃣ rating (desc)
  /// 3️⃣ rating count (desc)
  Stream<List<MentorProfile>> _streamMentors() {
    return FirebaseFirestore.instance
        .collection('mentor_profiles')
        .snapshots()
        .map((snapshot) {
      final mentors = snapshot.docs
          .map(MentorProfile.fromDoc)
      // hide explicitly disabled mentors
          .where((m) => m.isActive != false)
          .toList();

      mentors.sort((a, b) {
        //  Availability
        if (a.isFull != b.isFull) {
          return a.isFull ? 1 : -1;
        }

        //  Rating average (higher first)
        final aRating = a.ratingCount > 0 ? a.ratingAvg : -1;
        final bRating = b.ratingCount > 0 ? b.ratingAvg : -1;

        if (aRating != bRating) {
          return bRating.compareTo(aRating);
        }

        //  Rating count (tie breaker)
        return b.ratingCount.compareTo(a.ratingCount);
      });

      return mentors;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(t.t('error.unauthorized'))),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('mentorship.findMentor'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<List<MentorProfile>>(
        stream: _streamMentors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(t.t('common.error')));
          }

          final mentors = snapshot.data ?? [];

          if (mentors.isEmpty) {
            return Center(
              child: Text(
                t.t('mentorship.noMentors'),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final mentor = mentors[index];
              return _MentorCard(mentor: mentor);
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── MENTOR CARD ───────────────── */

class _MentorCard extends StatelessWidget {
  final MentorProfile mentor;

  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    final isFull = mentor.isFull;
    final hasRatings = mentor.ratingCount > 0;

    return Opacity(
      opacity: isFull ? 0.6 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isFull
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorProfileScreen(
                mentorId: mentor.id,
                allowEdit: false,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.12),
                backgroundImage:
                mentor.photoUrl != null ? NetworkImage(mentor.photoUrl!) : null,
                child: mentor.photoUrl == null
                    ? Icon(Icons.person, color: theme.colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mentor.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      mentor.department ?? '—',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),

                    // ⭐ Rating
                    hasRatings
                        ? Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          mentor.ratingAvg.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
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

                    const SizedBox(height: 6),

                    Text(
                      isFull
                          ? t.t('mentorship.fullyBooked')
                          : '${t.t('mentorship.available')} '
                          '(${mentor.activeMenteesCount}/${mentor.maxActiveMentees})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isFull ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isFull ? Colors.black26 : Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}