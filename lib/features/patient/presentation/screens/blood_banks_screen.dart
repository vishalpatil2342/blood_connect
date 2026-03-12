import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/features/patient/presentation/screens/add_blood_bank_screen.dart';
import 'package:blood_connect/features/patient/data/repositories/blood_bank_repository.dart';
import 'package:blood_connect/core/services/emergency_notification_service.dart';

class BloodBanksScreen extends ConsumerWidget {
  const BloodBanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloodBanksAsync = ref.watch(bloodBanksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE60000), // Primary Red
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Blood Banks',
          style: TextStyle(
            color: Colors.white, // White text
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBloodBankScreen()),
          );
        },
        backgroundColor: const Color(0xFFE60000),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: bloodBanksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE60000)),
          ),
          error: (error, stack) => Center(
            child: Text('Error loading blood banks: $error',
                style: const TextStyle(color: Colors.black87)),
          ),
          data: (bloodBanks) {
            if (bloodBanks.isEmpty) {
              return const Center(
                child: Text('No blood banks found.',
                    style: TextStyle(color: Colors.black87)),
              );
            }
            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              itemCount: bloodBanks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final bank = bloodBanks[index];
                return _buildBloodBankCard(context, ref, bank);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBloodBankCard(
      BuildContext context, WidgetRef ref, BloodBankModel bank) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Name & Location)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2A5F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital_rounded,
                      color: Color(0xFFFF2A5F), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.apartment_outlined,
                              color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              bank.hospitalName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              bank.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // Inventory
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Blood Stock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: bank.inventory.entries.map((entry) {
                      return _buildBloodTypeBadge(
                          context, ref, bank, entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Contact Blood Bank',
                style: TextStyle(
                  color: Color(0xFFFF2A5F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeBadge(BuildContext context, WidgetRef ref,
      BloodBankModel bank, String type, int count) {
    bool hasStock = count > 0;

    return GestureDetector(
      onTap: hasStock ? () => _showRequestDialog(context, ref, bank, type) : null,
      child: Container(
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: hasStock ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE60000), // Red Outline
            width: 1.5,
          ),
          boxShadow: hasStock
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF2A5F).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color:
                    hasStock ? const Color(0xFFE60000) : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count Units',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: hasStock ? const Color(0xFFE60000) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDialog(
      BuildContext context, WidgetRef ref, BloodBankModel bank, String type) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Request $type Blood',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Requesting from ${bank.name}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Patient Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(context); // Close dialog

              try {
                final remainingUnits =
                    await ref.read(bloodBankRepositoryProvider).requestBlood(
                          bankId: bank.id,
                          bloodType: type,
                          units: 1,
                          patientName: name,
                          urgency: 'Emergency',
                          location: bank.location,
                        );

                if (remainingUnits == 0) {
                  // Trigger notification
                  await ref
                      .read(emergencyNotificationServiceProvider)
                      .notifyBankStockZero(bank, type);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Emergency request submitted! $remainingUnits units remaining.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Request 1 Unit'),
          ),
        ],
      ),
    );
  }
}
