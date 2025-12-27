import 'package:flutter/material.dart';
import 'mentorship_request_sent_screen.dart';

class MentorProfileScreen extends StatelessWidget {
  final String name;
  final String department;

  const MentorProfileScreen({
    super.key,
    required this.name,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.headlineSmall),
            Text(department,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // placeholder bio text
            const Text(
              'This mentor has experience in guiding students and helping in academic improvement.',
              style: TextStyle(fontSize: 16),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MentorshipRequestSentScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Request Mentorship",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
