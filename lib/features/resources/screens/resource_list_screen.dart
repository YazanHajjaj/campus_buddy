import 'package:flutter/material.dart';

class ResourceListScreen extends StatefulWidget {
  const ResourceListScreen({super.key});

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  final List<_DummyResource> _dummyResources = const [
    _DummyResource(
      title: 'Calculus Summary Notes',
      description: 'Summary of chapters 1–3 with solved examples.',
      tags: ['Math', 'Calculus'],
      course: 'MATH101',
      uploadedAt: 'Nov 2025',
    ),
    _DummyResource(
      title: 'Programming I – Midterm Guide',
      description: 'Important theory + sample questions.',
      tags: ['Programming'],
      course: 'CS101',
      uploadedAt: 'Oct 2025',
    ),
    _DummyResource(
      title: 'Physics Lab Manual',
      description: 'Procedures and pre-lab questions.',
      tags: ['Physics', 'Lab'],
      course: 'PHYS105',
      uploadedAt: 'Sep 2025',
    ),
  ];

  final List<String> _sortOptions = const ['Newest', 'Most Popular'];
  final List<String> _filterTags = const ['All', 'Math', 'Programming', 'Physics', 'Lab'];

  String _selectedSort = 'Newest';
  String _selectedTag = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resources',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('Sort by:  '),
                    DropdownButton<String>(
                      value: _selectedSort,
                      items: _sortOptions
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedSort = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final label = _filterTags[index];
                final bool isSelected = _selectedTag == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedTag = label;                 
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _filterTags.length,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final resource = _dummyResources[index];
                return _ResourceCard(
                  resource: resource,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(resource.title),
                        content: Text(resource.description),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _dummyResources.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _DummyResource {
  final String title;
  final String description;
  final List<String> tags;
  final String course;
  final String uploadedAt;

  const _DummyResource({
    required this.title,
    required this.description,
    required this.tags,
    required this.course,
    required this.uploadedAt,
  });
}

class _ResourceCard extends StatelessWidget {
  final _DummyResource resource;
  final VoidCallback? onTap;

  const _ResourceCard({
    required this.resource,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                resource.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                resource.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: -6,
                children: [
                  for (final tag in resource.tags)
                    Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    resource.course,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    resource.uploadedAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
