import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@').first ?? 'Student';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------- WELCOME ----------
              Center(
                child: Text(
                  'Welcome, $userName 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --------- SEARCH BAR ----------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for classes or materials...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --------- BANNER ----------
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/study_material.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // ────────────── SECTIONS TITLE ──────────────
              Row(
                children: const [
                  Text(
                    'Sections',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 12),

              // --------- SECTIONS LIST ----------
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SectionItem('assets/images/coe.jpg', 'COE'),
                    SectionItem('assets/images/bme.jpg', 'BME'),
                    SectionItem('assets/images/ind.jpg', 'IND'),
                    SectionItem('assets/images/eee.jpg', 'EEE'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ───────── MOST SEARCHED COURSES TITLE ─────────
              Row(
                children: const [
                  Text(
                    'Most searched courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 12),

              // --------- MOST SEARCHED COURSES LIST ----------
              SizedBox(
                height: 230,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CourseCard(
                      imagePath: 'assets/images/calculus.jpg',
                      title: 'calculus 1',
                      description: 'description',
                    ),
                    CourseCard(
                      imagePath: 'assets/images/linear_algebra.jpg',
                      title: 'linear algebra',
                      description: 'description',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== WIDGETS ==================

class SectionItem extends StatelessWidget {
  final String imagePath;
  final String title;

  const SectionItem(this.imagePath, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const CourseCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              height: 140,
              width: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
