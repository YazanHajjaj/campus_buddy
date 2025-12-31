import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/event.dart';
import '../services/event_firestore_service.dart';
import 'event_create_screen.dart';
import 'event_details_screen.dart';
import 'event_calendar_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

enum _SortOption { soonest, latest }

class _EventListScreenState extends State<EventListScreen> {
  final _eventService = EventFirestoreService();
  late final Stream<List<Event>> _eventsStream;

  String _searchQuery = '';
  String? _selectedTag;
  _SortOption _sortOption = _SortOption.soonest;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventService.watchUpcomingEvents();
  }

  void _openCreate() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final t = AppLocalizations.of(context);

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('auth.loginRequired'))),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventCreateScreen(uid: uid),
      ),
    );
  }

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
        centerTitle: true,
        title: Text(t.t('events.title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: t.t('events.calendar'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EventCalendarScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: t.t('events.create'),
            onPressed: _openCreate,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, t),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(t.t('common.error')));
                }

                final allEvents = snapshot.data ?? [];

                if (allEvents.isEmpty) {
                  return Center(
                    child: Text(
                      t.t('events.empty'),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colors.outline),
                    ),
                  );
                }

                final tags = _extractTags(allEvents);
                final events = _applyFilters(allEvents);

                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      t.t('events.noMatch'),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colors.outline),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (tags.isNotEmpty)
                      _buildTagRow(tags, theme, colors, t),
                    Expanded(
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.fromLTRB(12, 8, 12, 16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _EventCard(
                            event: event,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EventDetailsScreen(
                                    eventId: event.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ───────── SEARCH BAR ───────── */

  Widget _buildSearchBar(
      ThemeData theme, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: t.t('events.search'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim()),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<_SortOption>(
            initialValue: _sortOption,
            onSelected: (v) => setState(() => _sortOption = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _SortOption.soonest,
                child: Text(t.t('events.sortSoonest')),
              ),
              PopupMenuItem(
                value: _SortOption.latest,
                child: Text(t.t('events.sortLatest')),
              ),
            ],
            child: Container(
              height: 46,
              padding:
              const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    t.t('events.sort'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ───────── TAG FILTER ───────── */

  Widget _buildTagRow(
      List<String> tags,
      ThemeData theme,
      ColorScheme colors,
      AppLocalizations t,
      ) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemCount: tags.length + 1,
        itemBuilder: (context, index) {
          final label =
          index == 0 ? t.t('common.all') : tags[index - 1];
          final selected =
          index == 0 ? _selectedTag == null : _selectedTag == label;

          return ChoiceChip(
            label: Text(label),
            selected: selected,
            selectedColor:
            colors.primary.withOpacity(0.12),
            labelStyle: TextStyle(
              color: selected
                  ? colors.primary
                  : colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() {
                _selectedTag =
                label == t.t('common.all') ? null : label;
              });
            },
          );
        },
      ),
    );
  }

  /* ───────── FILTER LOGIC ───────── */

  List<String> _extractTags(List<Event> events) {
    final set = <String>{};
    for (final e in events) {
      for (final t in e.tags) {
        if (t.trim().isNotEmpty) set.add(t.trim());
      }
    }
    return set.toList()..sort();
  }

  List<Event> _applyFilters(List<Event> events) {
    final now = DateTime.now();

    var result = events.where((e) {
      final cutoff = e.endTime.add(const Duration(days: 1));
      return cutoff.isAfter(now);
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.location.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedTag != null) {
      result = result.where((e) {
        return e.tags
            .map((t) => t.toLowerCase())
            .contains(_selectedTag!.toLowerCase());
      }).toList();
    }

    result.sort((a, b) {
      if (_sortOption == _SortOption.soonest) {
        return a.startTime.compareTo(b.startTime);
      }
      return b.startTime.compareTo(a.startTime);
    });

    return result;
  }
}

/* ───────── EVENT CARD ───────── */

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final date = event.startTime.toLocal();
    final dateLabel =
        '${date.day}/${date.month}/${date.year} • '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.place_outlined,
                      size: 16, color: colors.outline),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 16, color: colors.outline),
                  const SizedBox(width: 6),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (event.capacity > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${event.attendeesCount}/${event.capacity}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}