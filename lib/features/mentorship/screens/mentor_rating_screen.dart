import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import '../services/mentor_rating_service.dart';

/// Screen that allows a student to rate a mentor after mentorship
/// - Rating: 1–5 stars (required)
/// - Comment: optional
class MentorRatingScreen extends StatefulWidget {
  /// mentor_profiles/{mentorId}
  final String mentorId;

  const MentorRatingScreen({
    super.key,
    required this.mentorId,
  });

  @override
  State<MentorRatingScreen> createState() => _MentorRatingScreenState();
}

class _MentorRatingScreenState extends State<MentorRatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  final _ratingService = MentorRatingService();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Submits mentor rating and updates mentor aggregate safely
  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final user = _auth.currentUser;

    if (user == null) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('mentorship.ratingRequired')),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _ratingService.submitRating(
        mentorId: widget.mentorId,
        studentId: user.uid,
        rating: _rating,
        comment: _commentController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('common.error')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('mentorship.rateMentor'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── TITLE ─────
            Text(
              t.t('mentorship.howWasMentor'),
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            // ───── STAR RATING ─────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;

                return IconButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _rating = star),
                  icon: Icon(
                    Icons.star,
                    size: 36,
                    color: star <= _rating
                        ? Colors.amber
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ───── COMMENT ─────
            TextField(
              controller: _commentController,
              maxLines: 4,
              enabled: !_submitting,
              decoration: InputDecoration(
                labelText: t.t('mentorship.optionalComment'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const Spacer(),

            // ───── SUBMIT BUTTON ─────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  t.t('common.confirm'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
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