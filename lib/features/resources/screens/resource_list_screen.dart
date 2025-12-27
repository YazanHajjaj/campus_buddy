import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'resource_upload_screen.dart';
import 'resource_pdf_viewer.dart';

class ResourceListScreen extends StatefulWidget {
  const ResourceListScreen({super.key});

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  String _selectedCategory = 'All';

  Stream<QuerySnapshot> _query() {
    Query ref = FirebaseFirestore.instance
        .collection('resources')
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true);

    if (_selectedCategory != 'All') {
      ref = ref.where('category', isEqualTo: _selectedCategory);
    }

    return ref.orderBy('createdAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        title: const Text('Resources'),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2446C8),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ResourceUploadScreen(),
            ),
          );
        },
        child: const Icon(Icons.upload),
      ),

      body: Column(
        children: [
          // ───── FILTER BAR ─────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _filterChip('All'),
                _filterChip('Math'),
                _filterChip('Physics'),
                _filterChip('Programming'),
              ],
            ),
          ),

          const Divider(height: 1),

          // ───── RESOURCE LIST ─────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _query(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No resources found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 36,
                                color: Color(0xFF2446C8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Category: ${data['category'] ?? '—'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Course: ${data['courseCode'] ?? '—'}',
                            style: const TextStyle(fontSize: 12),
                          ),

                          const SizedBox(height: 12),

                          // ───── OPEN PDF (FIXED STYLE) ─────
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('resources')
                                    .doc(doc.id)
                                    .update({
                                  'openCount': FieldValue.increment(1),
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResourcePdfViewerScreen(
                                      url: data['fileUrl'],
                                      title: data['title'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              label: const Text(
                                'Open PDF',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _filterChip(String label) {
    final selected = _selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedCategory = label);
        },
      ),
    );
  }
}