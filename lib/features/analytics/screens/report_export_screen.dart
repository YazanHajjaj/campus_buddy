import 'package:flutter/material.dart';

class ReportExportScreen extends StatefulWidget {
  const ReportExportScreen({super.key});

  @override
  State<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends State<ReportExportScreen> {
  String _format = "CSV";
  String _scope = "System-wide";
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Report")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Export Settings", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Format
          DropdownButtonFormField<String>(
            value: _format,
            decoration: const InputDecoration(
              labelText: "Format",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "CSV", child: Text("CSV")),
              DropdownMenuItem(value: "PDF", child: Text("PDF")),
            ],
            onChanged: (v) => setState(() => _format = v ?? "CSV"),
          ),

          const SizedBox(height: 12),

          // Scope
          DropdownButtonFormField<String>(
            value: _scope,
            decoration: const InputDecoration(
              labelText: "Scope",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "System-wide", child: Text("System-wide")),
              DropdownMenuItem(value: "Events", child: Text("Events")),
              DropdownMenuItem(value: "Resources", child: Text("Resources")),
              DropdownMenuItem(value: "Mentorship", child: Text("Mentorship")),
            ],
            onChanged: (v) => setState(() => _scope = v ?? "System-wide"),
          ),

          const SizedBox(height: 12),

          // Date range
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              _range == null
                  ? "Pick Date Range"
                  : "${_range!.start.toLocal().toString().split(' ').first}  →  ${_range!.end.toLocal().toString().split(' ').first}",
            ),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
              );
              if (picked != null) setState(() => _range = picked);
            },
          ),

          const SizedBox(height: 18),
          Text("Preview (dummy)", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Format: $_format"),
                  Text("Scope: $_scope"),
                  Text("Range: ${_range == null ? "Not selected" : "Selected"}"),
                  const Divider(height: 22),
                  const Text(
                    "This will show a small preview table later.\n"
                    "For now it's a placeholder UI only.",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          FilledButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Export (placeholder)"),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Export not connected yet (UI only).")),
              );
            },
          ),
        ],
      ),
    );
  }
}
