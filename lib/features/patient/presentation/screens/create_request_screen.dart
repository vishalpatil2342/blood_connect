import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/shared/widgets/custom_text_field.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/features/patient/data/repositories/request_repository.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _cityController.dispose();
    _hospitalController.dispose();
    _bloodTypeController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final patientName = _patientNameController.text.trim();
    final city = _cityController.text.trim();
    final hospital = _hospitalController.text.trim();
    final bloodType = _bloodTypeController.text.trim();
    final mobile = _mobileController.text.trim();

    if (patientName.isEmpty || city.isEmpty || hospital.isEmpty || bloodType.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = BloodRequest(
        id: '', // Firestore .add() generates ID.
        patientName: patientName,
        city: city,
        hospital: hospital,
        bloodType: bloodType,
        mobile: mobile,
        requesterId: user.uid,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref.read(requestRepositoryProvider).createRequest(request);

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to request: $e')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 320, 
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  const SizedBox(height: 32),
                  const Text(
                    'Success',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your blood request has been successfully submitted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Back to Home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE60000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Create Blood Request',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _patientNameController,
              hint: 'John Doe',
              label: 'Patient Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bloodTypeController,
              hint: 'A+',
              label: 'Blood Type',
              prefixIcon: Icons.bloodtype_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cityController,
              hint: 'San Francisco',
              label: 'City',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hospitalController,
              hint: 'City General Hospital',
              label: 'Hospital',
              prefixIcon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _mobileController,
              hint: '+1 234 567 890',
              label: 'Mobile Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
