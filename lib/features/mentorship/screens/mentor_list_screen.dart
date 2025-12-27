import 'package:flutter/material.dart';
import 'mentor_profile_screen.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyMentors = [
      {'name': 'Dr. Sami Qureshi', 'department': 'Computer Engineering'},
      {'name': 'Sara Al-Farsi', 'department': 'Business Administration'},
      {'name': 'Prof. Lina Mahmoud', 'department': 'Psychology'},
      {'name': 'Omar Al-Salem', 'department': 'Software Engineering'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Mentor'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyMentors.length,
        itemBuilder: (context, index) {
          final mentor = dummyMentors[index];
          return Card(
            child: ListTile(
              title: Text(mentor['name']!),
              subtitle: Text(mentor['department']!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MentorProfileScreen(
                      name: mentor['name']!,
                      department: mentor['department']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
