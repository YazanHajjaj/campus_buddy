import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_firestore_service.dart';
import 'event_details_screen.dart';

/// Phase 4 – Events Calendar (Shahd)
/// Simple month grid that highlights days with events.
/// Uses EventFirestoreService.watchUpcomingEvents and groups by event.date.
class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final _eventService = EventFirestoreService();

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  late final Stream<List<Event>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventService.watchUpcomingEvents(limit: 200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Calendar'),
      ),
      body: StreamBuilder<List<Event>>(
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

          // Filter events to the current month
          final monthEvents = allEvents.where((e) {
            final d = e.date;
            return d.year == _focusedMonth.year &&
                d.month == _focusedMonth.month;
          }).toList();

          final eventsByDay = _groupByDay(monthEvents);

          final daysInMonth =
              DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
          final firstDayOfMonth =
              DateTime(_focusedMonth.year, _focusedMonth.month, 1);
          final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday → 7 = Sun

          return Column(
            children: [
              _buildMonthHeader(),
              const SizedBox(height: 8),
              _buildWeekdayRow(),
              const SizedBox(height: 4),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: daysInMonth + (firstWeekday - 1),
                  itemBuilder: (context, index) {
                    if (index < firstWeekday - 1) {
                      // leading blanks
                      return const SizedBox.shrink();
                    }

                    final dayNumber = index - (firstWeekday - 2);
                    final date = DateTime(_focusedMonth.year,
                        _focusedMonth.month, dayNumber);
                    final dateOnly = DateUtils.dateOnly(date);
                    final dayEvents = eventsByDay[dateOnly] ?? [];
                    final hasEvents = dayEvents.isNotEmpty;

                    final isSelected = _selectedDay != null &&
                        DateUtils.isSameDay(_selectedDay, date);

                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedDay = date;
                        });

                        if (dayEvents.isNotEmpty) {
                          _showDayEventsBottomSheet(context, date, dayEvents);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: isSelected ? 2 : 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.only(
                          top: 6,
                          left: 4,
                          right: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            if (hasEvents)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- helpers ----------

  Map<DateTime, List<Event>> _groupByDay(List<Event> events) {
    final map = <DateTime, List<Event>>{};
    for (final e in events) {
      final d = DateUtils.dateOnly(e.date);
      map.putIfAbsent(d, () => []);
      map[d]!.add(e);
    }
    return map;
  }

  Widget _buildMonthHeader() {
    final monthName = _monthName(_focusedMonth.month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          Text(
            '$monthName ${_focusedMonth.year}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: labels
            .map(
              (label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _showDayEventsBottomSheet(
    BuildContext context,
    DateTime date,
    List<Event> events,
  ) {
    final dateLabel =
        '${date.year}-${_two(date.month)}-${_two(date.day)}';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Events on $dateLabel'),
              ),
              const Divider(height: 0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text(e.location),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailsScreen(eventId: e.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
