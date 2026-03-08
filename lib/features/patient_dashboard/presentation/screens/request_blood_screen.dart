import 'package:blood_connect/features/auth/presentation/providers/blood_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:blood_connect/core/database/app_database.dart';
// Import your newly created provider file here

class RequestBloodScreen extends ConsumerStatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  ConsumerState<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends ConsumerState<RequestBloodScreen> {
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  
  String _selectedBloodGroup = 'A+';
  String _selectedUrgency = 'Normal';

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final newRequest = LocalBloodRequestsCompanion(
      patientName: drift.Value(_patientNameController.text),
      bloodGroup: drift.Value(_selectedBloodGroup),
      hospitalName: drift.Value(_hospitalController.text),
      urgency: drift.Value(_selectedUrgency),
      // Add other fields as you expand your Drift table
    );

    ref.read(bloodRequestActionProvider.notifier).addRequest(newRequest).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
      // Clear forms or navigate away
    });
  }

  @override
  Widget build(BuildContext context) {
    // You can replace your standard TextFields with controllers here
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Blood',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Build text fields mapping to your controllers
            TextField(
              controller: _patientNameController,
              decoration: const InputDecoration(labelText: 'Patient Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hospitalController,
              decoration: const InputDecoration(labelText: 'Hospital Name & Address'),
            ),
            // Implement Dropdowns for _selectedBloodGroup and _selectedUrgency
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitRequest,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}