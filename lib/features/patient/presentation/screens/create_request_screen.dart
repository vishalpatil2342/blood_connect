import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/shared/widgets/custom_text_field.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/core/services/emergency_notification_service.dart';
import 'package:blood_connect/features/patient/data/repositories/blood_bank_repository.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _mobileController =
      TextEditingController(text: '+91 ');
  String _selectedCity = '';
  String? _selectedHospital;
  String _selectedBloodType = 'A+';
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final patientName = _patientNameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (patientName.isEmpty ||
        _selectedHospital == null ||
        _selectedHospital!.isEmpty ||
        _selectedBloodType.isEmpty ||
        mobile.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selectedBank = ref.read(nearbyBloodBanksProvider).value?.firstWhere(
        (b) => b.hospitalName == _selectedHospital,
      );

      if (selectedBank == null) {
        throw Exception("Selected hospital data not found.");
      }

      final currentUnits = selectedBank.inventory[_selectedBloodType] ?? 0;

      if (currentUnits == 0) {
        // Trigger Emergency Notification Broadcast immediately
        final emergencyRequest = BloodRequest(
          id: '',
          patientName: patientName,
          city: _selectedCity,
          hospital: _selectedHospital!,
          bloodType: _selectedBloodType,
          mobile: mobile,
          requesterId: user.uid,
          status: 'pending', // Pending since we are relying on donors now
          createdAt: DateTime.now(),
        );

        await ref
            .read(emergencyNotificationServiceProvider)
            .saveAndBroadcastEmergencyRequest(emergencyRequest);

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank out of stock. Emergency broadcast sent to donors!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pop(context); // Close the request screen
        }
        return; // Exit early
      }

      // If we have stock, deduct 1 unit directly via transaction
      await ref.read(bloodBankRepositoryProvider).requestBlood(
            bankId: selectedBank.id,
            bloodType: _selectedBloodType,
            units: 1, // Defaulting to 1 unit per request based on UI
            patientName: patientName,
            urgency: 'Normal', // Default urgency
            location: _selectedCity,
            requesterId: user.uid,
            mobile: mobile,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to request: $e')));
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
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Success',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Create Blood Request',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18,
            ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _patientNameController,
                hint: 'John Doe',
                label: 'Patient Name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Blood Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBloodType,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                        items: _bloodGroups.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bloodtype_outlined,
                                  size: 20,
                                  color: Color(0xFFE60000),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedBloodType = val!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildHospitalDropdown(),
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalDropdown() {
    final bloodBanksAsync = ref.watch(nearbyBloodBanksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Blood Bank',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        bloodBanksAsync.when(
          loading: () => Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Container(
            height: 58,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text(
                'Error loading hospitals',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          data: (List<BloodBankModel> bloodBanks) {
            if (bloodBanks.isEmpty) {
              return Container(
                height: 58,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 20, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No blood banks found in your city. Please check later.',
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BloodBankModel>(
                  value: _selectedHospital != null
                      ? bloodBanks.firstWhere((b) => b.hospitalName == _selectedHospital,
                          orElse: () => bloodBanks.first)
                      : null,
                  hint: Row(
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text('Select Hospital',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                  items: bloodBanks.map((BloodBankModel bank) {
                    return DropdownMenuItem<BloodBankModel>(
                      value: bank,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_hospital_outlined,
                            size: 20,
                            color: Color(0xFFE60000),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  bank.hospitalName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${bank.name} - ${bank.location}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (BloodBankModel? val) {
                    if (val != null) {
                      setState(() {
                        _selectedHospital = val.hospitalName;
                        _selectedCity = val.location;
                      });
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
