import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/shared/widgets/custom_text_field.dart';
import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/features/patient/data/repositories/blood_bank_repository.dart';
import 'package:blood_connect/core/constants/indian_cities.dart';

class AddBloodBankScreen extends ConsumerStatefulWidget {
  const AddBloodBankScreen({super.key});

  @override
  ConsumerState<AddBloodBankScreen> createState() => _AddBloodBankScreenState();
}

class _AddBloodBankScreenState extends ConsumerState<AddBloodBankScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  String _selectedCity = IndianCities.locations.first;
  
  final Map<String, TextEditingController> _inventoryControllers = {
    'A+': TextEditingController(text: '0'),
    'A-': TextEditingController(text: '0'),
    'B+': TextEditingController(text: '0'),
    'B-': TextEditingController(text: '0'),
    'AB+': TextEditingController(text: '0'),
    'AB-': TextEditingController(text: '0'),
    'O+': TextEditingController(text: '0'),
    'O-': TextEditingController(text: '0'),
  };

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalNameController.dispose();
    for (var controller in _inventoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final hospitalName = _hospitalNameController.text.trim();
    if (name.isEmpty || hospitalName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final inventory = _inventoryControllers.map(
        (key, controller) => MapEntry(key, int.tryParse(controller.text) ?? 0),
      );

      final bloodBank = BloodBankModel(
        id: '', // Firestore generates ID
        name: name,
        hospitalName: hospitalName,
        location: _selectedCity,
        inventory: inventory,
      );

      await ref.read(bloodBankRepositoryProvider).addBloodBank(bloodBank);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blood Bank added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add blood bank: $e')),
        );
      }
    }
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
          'Add Blood Bank',
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
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _nameController,
              hint: 'e.g. Red Cross Blood Bank',
              label: 'Blood Bank Name',
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hospitalNameController,
              hint: 'e.g. City General Hospital',
              label: 'Hospital Name',
              prefixIcon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'City / Location',
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
                      value: _selectedCity,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                      items: IndianCities.locations.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: Color(0xFFE60000),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  city,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCity = val!);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Blood Inventory (Units)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.7,
              ),
              itemCount: _inventoryControllers.length,
              itemBuilder: (context, index) {
                final type = _inventoryControllers.keys.elementAt(index);
                return CustomTextField(
                  controller: _inventoryControllers[type]!,
                  hint: '0',
                  label: type,
                  prefixIcon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.number,
                );
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
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
                        'Add Blood Bank',
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
    );
  }
}
