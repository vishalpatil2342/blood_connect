import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:blood_connect/core/constants/indian_cities.dart';
import 'package:blood_connect/core/models/user_model.dart';
import 'package:blood_connect/core/services/emergency_notification_service.dart';

class FindDonorsScreen extends ConsumerWidget {
  const FindDonorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredDonorsAsync = ref.watch(filteredDonorsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Find Donors',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Donors List (Scrolling layer)
          filteredDonorsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFE60000)),
            ),
            error: (err, stack) =>
                Center(child: Text('Error loading donors: $err')),
            data: (donors) {
              if (donors.isEmpty) {
                return const Center(
                  child: Text('No donors found at the moment.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 100, // Space for the floating search bar
                  bottom: 24.0,
                ),
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  final donor = donors[index];

                  return _buildDonorCard(
                    context: context,
                    ref: ref,
                    donor: donor,
                  );
                },
              );
            },
          ),

          // Floating Search and Filter Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.8, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TextField(
                          onChanged: (value) {
                            ref
                                .read(donorSearchQueryProvider.notifier)
                                .setQuery(value);
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search donors...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFFF2A5F),
                              size: 24,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _showFilterSheet(context, ref);
                        },
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFFFF2A5F),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard({
    required BuildContext context,
    required WidgetRef ref,
    required UserModel donor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2A5F).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image with subtle border
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFF2A5F).withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: donor.photoUrl.isNotEmpty
                      ? Image.network(
                          donor.photoUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.person,
                                color: Colors.grey, size: 30),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.person,
                              color: Colors.grey, size: 30),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFFFF2A5F),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            donor.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Availability Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: donor.isAvailableForDonation
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: donor.isAvailableForDonation
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: donor.isAvailableForDonation ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            donor.isAvailableForDonation ? 'Available Now' : 'Not Available',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: donor.isAvailableForDonation ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Prominent Blood Type Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2A5F).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF2A5F).withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop, color: Color(0xFFFF2A5F), size: 24),
                    const SizedBox(height: 2),
                    Text(
                      donor.bloodType,
                      style: const TextStyle(
                        color: Color(0xFFFF2A5F),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 16),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: donor.isAvailableForDonation
                  ? () async {
                      final currentUser = ref.read(userProfileProvider).value;
                      if (currentUser == null) return;

                      try {
                        await ref.read(emergencyNotificationServiceProvider).notifySpecificDonor(
                              donorId: donor.uid,
                              senderId: currentUser.uid,
                              senderName: currentUser.name,
                              phoneNumber: currentUser.phone,
                              bloodType: donor.bloodType,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notification sent to ${donor.name}!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error: Could not notify donor.'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2A5F).withValues(alpha: 0.1),
                foregroundColor: const Color(0xFFFF2A5F),
                disabledBackgroundColor: Colors.grey.shade100,
                disabledForegroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Request Blood',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _FilterDonorsSheet();
      },
    );
  }
}

class _FilterDonorsSheet extends ConsumerStatefulWidget {
  const _FilterDonorsSheet();

  @override
  ConsumerState<_FilterDonorsSheet> createState() => _FilterDonorsSheetState();
}

class _FilterDonorsSheetState extends ConsumerState<_FilterDonorsSheet> {
  String? _selectedBloodType;
  String? _selectedLocation;
  bool _isAvailableOnly = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current provider state
    _isAvailableOnly = ref.read(donorAvailabilityFilterProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    // 1. Build a composite query from blood type and location
    // Currently the search query scans for bloodType OR name OR location matching exactly
    // So if they select 'O+' and location 'Dhaka', we can just join them or handle it in provider

    String combinedQuery = '';
    if (_selectedBloodType != null) {
      combinedQuery += _selectedBloodType!;
    }

    if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
      if (combinedQuery.isNotEmpty) combinedQuery += ' ';
      combinedQuery += _selectedLocation!;
    }

    ref.read(donorAvailabilityFilterProvider.notifier).toggle(_isAvailableOnly);
    ref.read(donorSearchQueryProvider.notifier).setQuery(combinedQuery);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedLocation = null;
      _isAvailableOnly = false;
    });
    ref.read(donorAvailabilityFilterProvider.notifier).toggle(false);
    ref.read(donorSearchQueryProvider.notifier).setQuery('');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Donors',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Blood Group Section
          const Text(
            'Blood Group',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _bloodTypes.map((type) {
              final isSelected = _selectedBloodType == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBloodType = isSelected ? null : type;
                  });
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF2A5F) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF2A5F)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF2A5F,
                              ).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Location Section
          const Text(
            'Location / City',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLocation,
                isExpanded: true,
                hint: Text(
                  'Select a City',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
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
                          color: Color(0xFFFF2A5F),
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
                  setState(() => _selectedLocation = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Availability Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isAvailableOnly ? const Color(0xFFFF2A5F).withValues(alpha: 0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isAvailableOnly ? const Color(0xFFFF2A5F) : Colors.grey.shade200, 
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: _isAvailableOnly ? const Color(0xFFFF2A5F) : Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Available to Donate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isAvailableOnly,
                  activeThumbColor: const Color(0xFFFF2A5F),
                  onChanged: (value) {
                    setState(() {
                      _isAvailableOnly = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFF2A5F),
                    elevation: 10,
                    shadowColor: const Color(0xFFFF2A5F).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
