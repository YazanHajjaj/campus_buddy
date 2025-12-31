import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/event.dart';
import '../services/event_firestore_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _eventService = EventFirestoreService();
  final _auth = FirebaseAuth.instance;

  late final Stream<Event?> _eventStream;
  bool _rsvpLoading = false;

  @override
  void initState() {
    super.initState();
    _eventStream = _eventService.watchEventById(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        centerTitle: true,
        title: Text(t.t('events.details')),
      ),
      body: StreamBuilder<Event?>(
        stream: _eventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(t.t('common.error')));
          }

          final event = snapshot.data;
          if (event == null) {
            return Center(child: Text(t.t('events.notFound')));
          }

          return _EventDetailsBody(
            event: event,
            uid: uid,
            eventService: _eventService,
            rsvpLoading: _rsvpLoading,
            onRsvpStateChange: (v) {
              setState(() => _rsvpLoading = v);
            },
          );
        },
      ),
    );
  }
}

/* ───────────────────────────────────────────── */

class _EventDetailsBody extends StatelessWidget {
  final Event event;
  final String? uid;
  final EventFirestoreService eventService;
  final bool rsvpLoading;
  final void Function(bool) onRsvpStateChange;

  const _EventDetailsBody({
    required this.event,
    required this.uid,
    required this.eventService,
    required this.rsvpLoading,
    required this.onRsvpStateChange,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final now = DateTime.now();
    final isPastEvent = event.endTime.isBefore(now);
    final isOrganizer = uid != null && uid == event.createdBy;

    final hasCapacity = event.capacity > 0;
    final isFull =
        hasCapacity && event.attendeesCount >= event.capacity;

    final progress = hasCapacity
        ? (event.attendeesCount / event.capacity).clamp(0.0, 1.0)
        : 0.0;

    return FutureBuilder<bool>(
      future: uid == null
          ? Future.value(false)
          : eventService.hasUserRsvped(
        eventId: event.id,
        uid: uid!,
      ),
      builder: (context, rsvpSnap) {
        final hasRsvped = rsvpSnap.data == true;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /* ───── IMAGE ───── */
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  event.imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.event, size: 48),
                ),
              ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    if (!(Platform.isAndroid || Platform.isIOS)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.t('events.shareUnavailable')),
                        ),
                      );
                      return;
                    }

                    Share.share(
                      '${event.title}\n'
                          '${_format(event.startTime)} → ${_format(event.endTime)}\n'
                          '${event.location}',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              isOrganizer
                  ? t.t('events.organizedByYou')
                  : t.t('events.campusEvent'),
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 12),

            Text(event.description),

            const SizedBox(height: 20),

            _InfoRow(
              icon: Icons.place_outlined,
              label: t.t('events.location'),
              value: event.location,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: t.t('events.from'),
              value: _format(event.startTime),
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: t.t('events.to'),
              value: _format(event.endTime),
            ),

            const SizedBox(height: 16),

            if (event.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.tags
                    .map(
                      (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: colors.surfaceVariant,
                  ),
                )
                    .toList(),
              ),

            const SizedBox(height: 20),

            if (hasCapacity)
              _CapacityCard(
                attending: event.attendeesCount,
                capacity: event.capacity,
                progress: progress,
              ),

            const SizedBox(height: 24),

            if (isPastEvent)
              Text(
                t.t('events.ended'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.outline,
                ),
              )
            else
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: uid == null ||
                      rsvpLoading ||
                      (isFull && !hasRsvped)
                      ? null
                      : () async {
                    onRsvpStateChange(true);
                    try {
                      if (hasRsvped) {
                        await eventService.cancelRsvp(
                          eventId: event.id,
                          uid: uid!,
                        );
                      } else {
                        await eventService.rsvpToEvent(
                          eventId: event.id,
                          uid: uid!,
                        );
                      }
                    } finally {
                      onRsvpStateChange(false);
                    }
                  },
                  child: rsvpLoading
                      ? const CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                      : Text(
                    hasRsvped
                        ? t.t('events.cancelRsvp')
                        : t.t('events.reserve'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _format(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

/* ───────────────────────────────────────────── */

class _CapacityCard extends StatelessWidget {
  final int attending;
  final int capacity;
  final double progress;

  const _CapacityCard({
    required this.attending,
    required this.capacity,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('events.capacity'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('$attending / $capacity'),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            color: colors.primary,
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────────────────────────── */

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}