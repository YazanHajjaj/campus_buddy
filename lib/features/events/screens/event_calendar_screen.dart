import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/event.dart';
import '../services/event_firestore_service.dart';
import 'event_details_screen.dart';

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
    _eventsStream = _eventService.watchUpcomingEvents(limit: 300);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final today = DateUtils.dateOnly(DateTime.now());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        centerTitle: true,
        title: Text(t.t('events.calendar')),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(t.t('common.error')));
          }

          final now = DateTime.now();

          final validEvents = (snapshot.data ?? []).where((e) {
            return e.endTime
                .add(const Duration(days: 1))
                .isAfter(now);
          }).toList();

          final monthEvents = validEvents.where((e) {
            return e.date.year == _focusedMonth.year &&
                e.date.month == _focusedMonth.month;
          }).toList();

          final eventsByDay = _groupByDay(monthEvents);

          final daysInMonth = DateUtils.getDaysInMonth(
            _focusedMonth.year,
            _focusedMonth.month,
          );

          final firstDayOfMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month, 1);
          final firstWeekday = firstDayOfMonth.weekday;

          return Column(
            children: [
              _buildMonthHeader(t),
              const SizedBox(height: 8),
              _buildWeekdayRow(t),
              const SizedBox(height: 6),
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
                      return const SizedBox.shrink();
                    }

                    final dayNumber = index - (firstWeekday - 2);
                    final date = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month,
                      dayNumber,
                    );

                    final dateOnly = DateUtils.dateOnly(date);
                    final dayEvents = eventsByDay[dateOnly] ?? [];
                    final hasEvents = dayEvents.isNotEmpty;

                    final isSelected = _selectedDay != null &&
                        DateUtils.isSameDay(_selectedDay, date);
                    final isToday =
                    DateUtils.isSameDay(today, dateOnly);

                    return GestureDetector(
                      onTap: hasEvents
                          ? () {
                        setState(() => _selectedDay = date);
                        _showDayEventsBottomSheet(
                          context,
                          date,
                          dayEvents,
                        );
                      }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withOpacity(0.12)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday
                                ? colors.primary
                                : colors.outlineVariant,
                            width: isToday ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isToday
                                      ? colors.primary
                                      : colors.onSurface,
                                ),
                              ),
                              if (hasEvents) const SizedBox(height: 2),
                              if (hasEvents)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
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

  /* ───────── HELPERS ───────── */

  Map<DateTime, List<Event>> _groupByDay(List<Event> events) {
    final map = <DateTime, List<Event>>{};
    for (final e in events) {
      final d = DateUtils.dateOnly(e.date);
      map.putIfAbsent(d, () => []);
      map[d]!.add(e);
    }
    return map;
  }

  Widget _buildMonthHeader(AppLocalizations t) {
    final monthName = t.t('months.${_focusedMonth.month}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                  1,
                );
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            '$monthName ${_focusedMonth.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                  1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(AppLocalizations t) {
    final labels = [
      t.t('weekdays.mon'),
      t.t('weekdays.tue'),
      t.t('weekdays.wed'),
      t.t('weekdays.thu'),
      t.t('weekdays.fri'),
      t.t('weekdays.sat'),
      t.t('weekdays.sun'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: labels
            .map(
              (l) => Expanded(
            child: Center(
              child: Text(
                l,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  void _showDayEventsBottomSheet(
      BuildContext context,
      DateTime date,
      List<Event> events,
      ) {
    final t = AppLocalizations.of(context);
    final dateLabel = '${date.day}/${date.month}/${date.year}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '${t.t('events.onDate')} $dateLabel',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text(e.location),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
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
}