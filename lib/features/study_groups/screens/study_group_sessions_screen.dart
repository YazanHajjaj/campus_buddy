import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/study_group_session.dart';
import '../services/study_group_session_service.dart';
import 'create_study_group_session_screen.dart';

class StudyGroupSessionsScreen extends StatelessWidget {
  final String groupId;
  final String groupTitle;
  final String ownerId;

  const StudyGroupSessionsScreen({
    super.key,
    required this.groupId,
    required this.groupTitle,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = StudyGroupSessionService();

    final isOwner = uid != null && uid == ownerId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('studyGroup.sessions'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateStudyGroupSessionScreen(
                groupId: groupId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: StreamBuilder<List<StudyGroupSession>>(
        stream: service.streamSessions(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return Center(
              child: Text(
                t.t('studyGroup.noSessions'),
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (_, i) {
              final s = sessions[i];
              final dateLabel =
              DateFormat('EEE, MMM d').format(s.date.toDate());

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    s.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '$dateLabel • ${s.startTime} – ${s.endTime}\n${s.location}',
                  ),
                  isThreeLine: true,
                  trailing: isOwner
                      ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      service.deleteSession(
                        groupId: groupId,
                        sessionId: s.id,
                      );
                    },
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}