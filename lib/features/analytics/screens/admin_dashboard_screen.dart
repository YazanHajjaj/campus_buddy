import 'package:flutter/material.dart';
import 'report_export_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Export Report',
            icon: const Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportExportScreen()),
              );
            },
          ),
        ],
      ),

      // ✅ Fixed bottom button (won’t scroll away)
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Export Report"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportExportScreen()),
              );
            },
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // ✅ space for bottom button
        children: [
          Text(
            "System Overview",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          // ✅ Responsive grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 600 ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: const [
                  _StatCard(title: "Active Students", value: "128"),
                  _StatCard(title: "Mentors", value: "14"),
                  _StatCard(title: "Events This Month", value: "6"),
                  _StatCard(title: "Top Resource Downloads", value: "42"),
                ],
              );
            },
          ),

          const SizedBox(height: 18),
          Text(
            "Charts (placeholder)",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          const _ChartPlaceholder(title: "Activity Trend (Last 7 days)"),
          const SizedBox(height: 12),
          const _ChartPlaceholder(title: "User Categories (Students vs Mentors)"),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),

            // ✅ Prevent overflow for large values
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final String title;

  const _ChartPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(14),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            const Expanded(
              child: Center(
                child: Text("Chart goes here (dummy)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
