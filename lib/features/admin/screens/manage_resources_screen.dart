import 'package:flutter/material.dart';

class ManageResourcesScreen extends StatelessWidget {
  const ManageResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Resources"),
      ),
      body: const Center(
        child: Text("Manage Resources (UI only)"),
      ),
    );
  }
}
