import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_firestore_service.dart';
import 'event_details_screen.dart';

/// Phase 4 – Events List UI (Shahd)
/// Uses EventFirestoreService.watchUpcomingEvents to show live events
/// with basic search, filtering, and sorting.
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

enum _SortOption {
  soonest,
  latest,
}

class _EventListScreenState extends State<EventListScreen> {
  final _eventService = EventFirestoreService();

  late final Stream<List<Event>> _eventsStream;

  String _searchQuery = '';
  String? _selectedTag; // null = all tags
  _SortOption _sortOption = _SortOption.soonest;

  @override
  void initState() {
    super.initState();
    // Single shared stream for the screen
    _eventsStream = _eventService.watchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
      ),
      body: Column(
        children: [
          _buildSearchAndSortBar(),
          const SizedBox(height: 4),
          // Tags row depends on the incoming events → built inside StreamBuilder
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading events: ${snapshot.error}'),
                  );
                }

                final allEvents = snapshot.data ?? [];

                if (allEvents.isEmpty) {
                  return const Center(
                    child: Text('No upcoming events yet.'),
                  );
                }

                final uniqueTags = _extractTags(allEvents);
                final filtered = _applyFilters(allEvents);

                return Column(
                  children: [
                    if (uniqueTags.isNotEmpty)
                      _buildTagFilterRow(uniqueTags)
                    else
                      const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          return _EventCard(
                            event: event,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailsScreen(eventId: event.id),
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

  // ---------- UI helpers ----------

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Search
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Sort dropdown
          PopupMenuButton<_SortOption>(
            initialValue: _sortOption,
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _SortOption.soonest,
                child: Text('Soonest first'),
              ),
              const PopupMenuItem(
                value: _SortOption.latest,
                child: Text('Latest first'),
              ),
            ],
            child: Row(
              children: const [
                Icon(Icons.sort),
                SizedBox(width: 4),
                Text('Sort'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilterRow(List<String> tags) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: tags.length + 1, // + "All" chip
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedTag == null;
            return ChoiceChip(
              label: const Text('All'),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedTag = null;
                });
              },
            );
          }

          final tag = tags[index - 1];
          final isSelected = _selectedTag == tag;

          return ChoiceChip(
            label: Text(tag),
            selected: isSelected,
            labelStyle: isSelected
                ? theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  )
                : null,
            onSelected: (_) {
              setState(() {
                _selectedTag = isSelected ? null : tag;
              });
            },
          );
        },
      ),
    );
  }

  // ---------- filtering / sorting ----------

  List<String> _extractTags(List<Event> events) {
    final set = <String>{};
    for (final e in events) {
      for (final tag in e.tags) {
        if (tag.trim().isNotEmpty) {
          set.add(tag.trim());
        }
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  List<Event> _applyFilters(List<Event> events) {
    var result = List<Event>.from(events);

    // Search by title or location
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        final title = e.title.toLowerCase();
        final location = e.location.toLowerCase();
        return title.contains(q) || location.contains(q);
      }).toList();
    }

    // Tag filter
    if (_selectedTag != null) {
      result = result
          .where((e) => e.tags.map((t) => t.toLowerCase()).contains(
                _selectedTag!.toLowerCase(),
              ))
          .toList();
    }

    // Sort
    result.sort((a, b) {
      final aTime = a.startTime;
      final bTime = b.startTime;

      if (_sortOption == _SortOption.soonest) {
        return aTime.compareTo(bTime);
      } else {
        return bTime.compareTo(aTime);
      }
    });

    return result;
  }
}

/// Single event card in the list.
class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const _EventCard({
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = event.date.toLocal();
    final start = event.startTime.toLocal();
    final end = event.endTime.toLocal();

    final dateLabel = '${date.year}-${_two(date.month)}-${_two(date.day)}';
    final timeLabel =
        '${_two(start.hour)}:${_two(start.minute)} - ${_two(end.hour)}:${_two(end.minute)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeadingImageOrIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMainInfo(context, dateLabel, timeLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingImageOrIcon() {
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          event.imageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 0.4),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.event),
    );
  }

  Widget _buildMainInfo(
    BuildContext context,
    String dateLabel,
    String timeLabel,
  ) {
    final theme = Theme.of(context);
    final capacity = event.capacity;
    final attending = event.attendeesCount;
    final hasCapacity = capacity > 0;
    final progress =
        hasCapacity ? (attending / capacity).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: theme.textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          event.location,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.schedule, size: 16),
            const SizedBox(width: 4),
            Text(
              '$dateLabel • $timeLabel',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (event.tags.isNotEmpty)
          Wrap(
            spacing: 4,
            runSpacing: -4,
            children: event.tags
                .take(3)
                .map(
                  (t) => Chip(
                    label: Text(
                      t,
                      style: theme.textTheme.bodySmall,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                )
                .toList(),
          ),
        if (hasCapacity) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(value: progress),
              ),
              const SizedBox(width: 8),
              Text(
                '$attending / $capacity',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
