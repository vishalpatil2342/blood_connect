import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:blood_connect/features/patient/data/repositories/blood_bank_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/donation_repository.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/features/patient/data/repositories/request_repository.dart';
import 'package:blood_connect/core/models/donation_model.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRecordDonationDialog() {
    showDialog(
      context: context,
      builder: (context) => _RecordDonationDialog(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE60000), // Primary Red
          iconTheme: const IconThemeData(color: Colors.white), // Makes back button white if present
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: const Color(0xFFFF2A5F),
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent, // Disable the bottom border
                tabs: const [
                  Tab(text: 'My Donations'),
                  Tab(text: 'My Requests'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Donations Tab
            _DonationsList(),
            
            // Requests Tab
            _RequestsList(),
          ],
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return _tabController.index == 0
                ? FloatingActionButton.extended(
                    onPressed: _showRecordDonationDialog,
                    backgroundColor: const Color(0xFFE60000),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'New Donation',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
    );
  }
}

class _DonationsList extends ConsumerWidget {
  const _DonationsList();

  // Helper inside to format the date
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(myDonationsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE60000))),
      error: (err, stack) => Center(child: Text('Error loading donations: $err')),
      data: (donations) {
        if (donations.isEmpty) {
          return const Center(child: Text("You haven't made any donations yet."));
        }

        // Sort by date descending locally
        final sortedDonations = [...donations]
          ..sort((a, b) => b.donationDate.compareTo(a.donationDate));

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: sortedDonations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final donation = sortedDonations[index];

            return _buildActivityCard(
              title: 'Donation Successful',
              subTitle: donation.patientName != null 
                  ? 'To ${donation.patientName}' 
                  : 'At ${donation.hospital}',
              date: _formatDate(donation.donationDate),
              bloodType: donation.bloodType,
              status: donation.status.toUpperCase(),
              statusColor: donation.status.toLowerCase() == 'completed' ? Colors.green : Colors.orange,
              icon: Icons.volunteer_activism_outlined,
              actionWidget: PopupMenuButton<String>(
                onSelected: (newValue) {
                  if (newValue != donation.status.toLowerCase()) {
                    ref.read(donationRepositoryProvider).updateDonationStatus(donation.id, newValue);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Update',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey.shade700),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'pending',
                    child: Text('Pending', style: TextStyle(fontSize: 14)),
                  ),
                  const PopupMenuItem(
                    value: 'completed',
                    child: Text('Completed', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RequestsList extends ConsumerWidget {
  const _RequestsList();

  // Helper inside to format the date
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(myRequestsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE60000))),
      error: (err, stack) => Center(child: Text('Error loading activity: $err')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text("You haven't made any requests yet."));
        }

        // Sort by date descending locally
        final sortedRequests = [...requests]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: sortedRequests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = sortedRequests[index];

            return _buildActivityCard(
              title: 'Patient: ${request.patientName}',
              subTitle: 'At ${request.hospital}',
              requester: 'By You',
              date: _formatDate(request.createdAt),
              bloodType: request.bloodType,
              status: request.status.toUpperCase(),
              statusColor: request.status.toLowerCase() == 'pending' ? Colors.orange : Colors.green,
              icon: Icons.bloodtype_outlined,
              actionWidget: IconButton(
                onPressed: () => _showDeleteConfirmation(context, ref, request),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                tooltip: 'Delete Request',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, BloodRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Request?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this blood request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(requestRepositoryProvider).deleteRequest(request.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request deleted successfully'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

Widget _buildActivityCard({
  required String title,
  required String subTitle,
  required String date,
  required String bloodType,
  required String status,
  required Color statusColor,
  required IconData icon,
  String? requester,
  Widget? actionWidget,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        // Icon Container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF2A5F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFFFF2A5F), size: 28),
        ),
        const SizedBox(width: 16),
        
        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (requester != null) ...[
                const SizedBox(height: 2),
                Text(
                  requester,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF2A5F).withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        
        // Status and Blood Type
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              bloodType,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFFFF2A5F),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            if (actionWidget != null) ...[
              const SizedBox(height: 8),
              actionWidget,
            ],
          ],
        ),
      ],
    ),
  );
}

class _RecordDonationDialog extends StatefulWidget {
  final WidgetRef ref;
  const _RecordDonationDialog({required this.ref});

  @override
  State<_RecordDonationDialog> createState() => _RecordDonationDialogState();
}

class _RecordDonationDialogState extends State<_RecordDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBankId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBankId == null) return;

    final userProfile = widget.ref.read(userProfileProvider).value;
    if (userProfile == null || userProfile.bloodType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find your blood type. Please update your profile.')),
      );
      return;
    }

    final banks = widget.ref.read(bloodBanksProvider).value ?? [];
    final selectedBank = banks.firstWhere((b) => b.id == _selectedBankId);

    setState(() => _isLoading = true);

    try {
      final user = widget.ref.read(firebaseAuthProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final donation = Donation(
        id: '',
        donorId: user.uid,
        hospital: selectedBank.hospitalName,
        bloodType: userProfile.bloodType,
        status: 'completed',
        donationDate: DateTime.now(),
      );

      await widget.ref.read(bloodBankRepositoryProvider).recordDonation(
            bankId: _selectedBankId!,
            donationData: donation.toMap(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('Bank is Full')
            ? 'Bank is Full'
            : 'Failed to record donation: $e';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloodBanksAsync = widget.ref.watch(bloodBanksProvider);
    final userProfileAsync = widget.ref.watch(userProfileProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Record New Donation',
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE60000)),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for your generosity! Please select the blood bank where you donated.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            bloodBanksAsync.when(
              data: (banks) => DropdownButtonFormField<String>(
              initialValue: _selectedBankId,
                decoration: InputDecoration(
                  labelText: 'Blood Bank',
                  prefixIcon: const Icon(Icons.local_hospital_outlined, color: Color(0xFFE60000)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE60000), width: 2),
                  ),
                ),
                items: () {
                  final uniqueBanks = <String, String>{};
                  for (var bank in banks) {
                    if (!uniqueBanks.containsKey(bank.hospitalName)) {
                      uniqueBanks[bank.hospitalName] = bank.id;
                    }
                  }
                  return uniqueBanks.entries.map((entry) => DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.key),
                  )).toList();
                }(),
                onChanged: (v) => setState(() => _selectedBankId = v),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading blood banks: $err'),
            ),
            const SizedBox(height: 16),
            userProfileAsync.when(
              data: (user) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bloodtype_outlined, color: Color(0xFFE60000)),
                    const SizedBox(width: 8),
                    Text(
                      'Your Blood Type: ${user?.bloodType ?? "Unknown"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE60000),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Submit'),
        ),
      ],
    );
  }
}

