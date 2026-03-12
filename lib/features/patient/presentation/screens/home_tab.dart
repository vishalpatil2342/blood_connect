import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:blood_connect/core/models/donation_model.dart';
import 'package:blood_connect/features/patient/data/repositories/notification_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/request_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/donation_repository.dart';
import 'package:blood_connect/core/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/features/patient/presentation/screens/notifications_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/find_donors_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/create_request_screen.dart';
import 'package:blood_connect/core/utils/blood_compatibility.dart';
import 'package:blood_connect/core/models/blood_bank_model.dart';
import 'package:blood_connect/features/patient/data/repositories/blood_bank_repository.dart';
import 'package:blood_connect/core/providers/firebase_providers.dart';
import 'package:blood_connect/core/services/emergency_notification_service.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Removed SafeArea from the very top so the red header can go behind the status bar
    return SingleChildScrollView(
      // Padding is removed from here so the top red container can be full width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. New Red Header Section
          _buildRedHeader(context, ref),
          
          // 2. The Rest of the Content (Wrapped in padding to maintain margins)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats / Quick Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.search_rounded,
                        title: 'Find\nDonors',
                        backgroundColor: Colors.blue.shade50,
                        iconColor: Colors.blue.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FindDonorsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.bloodtype_rounded,
                        title: 'Book\nRequest', // Updated text to match your image somewhat
                        backgroundColor: const Color(0xFFFFF0F5),
                        iconColor: const Color(0xFFE60000),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateRequestScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Nearby Blood Banks Section
                _buildNearbyBloodBanks(context, ref),

              ],
            ),
          ),
          
          // Emergency Requests Section with White Background
          Container(
            color: Colors.white, // White Background
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Urgent Requests Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Blood Requests',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.black87, // Dark text for contrast
                      ),
                    ),
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFE60000)), // Red Icon
                  ],
                ),
                const SizedBox(height: 16),
                
                // Urgent Request List
                ref.watch(compatibleEmergencyRequestsProvider).when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFFE60000)),
                    ),
                  ),
                  error: (error, stack) => const Center(
                    child: Text('Error loading requests', style: TextStyle(color: Colors.black87)),
                  ),
                  data: (requests) {
                    if (requests.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text("No emergency requests yet.", style: TextStyle(color: Colors.black87)),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length > 10 ? 10 : requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(context, ref, requests[index]);
                      },
                    );
                  },
                ),
                
                // Extra spacing at the bottom so the floating nav bar doesn't cover content
                const SizedBox(height: 80), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The new top red area matching your image
  Widget _buildRedHeader(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final userName = userAsync.when(
      data: (user) {
        if (user == null || user.name.trim().isEmpty) {
          return 'User';
        }
        return user.name;
      },
      loading: () => '...',
      error: (err, stack) => 'User',
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        // Add dynamic top padding so the text doesn't hide behind the phone's status bar clock/battery
        top: MediaQuery.of(context).padding.top + 20, 
        left: 24,
        right: 24,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        // Added a slight gradient to make it look premium like the image
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4D4D), // Lighter red
            Color(0xFFE60000), // Primary red
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello, $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Notification Bell Icon with slight translucent background
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: ref.watch(notificationsProvider).when(
                  data: (notifications) {
                    final unreadCount = notifications.where((n) => !n.isRead).length;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.yellow, // Contrast with red background
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                  ),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Let's make a difference together!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your Blood Saves Lives!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyBloodBanks(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final banksAsync = ref.watch(bloodBanksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Blood Banks Near You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE60000))),
          error: (err, _) => Text('Error: $err'),
          data: (user) {
            final userCity = user?.location ?? 'Unknown';
            return banksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE60000))),
              error: (err, _) => Text('Error: $err'),
              data: (banks) {
                final nearbyBanks = banks
                    .where((b) =>
                        b.location.trim().toLowerCase() ==
                        userCity.trim().toLowerCase())
                    .toList();

                if (nearbyBanks.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.location_off_outlined,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No blood banks found in $userCity',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: 360, // Reduced from 440 to match smaller card size
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nearbyBanks.length,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final bank = nearbyBanks[index];
                      return _buildNearbyBankCard(context, ref, bank);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNearbyBankCard(BuildContext context, WidgetRef ref, BloodBankModel bank) {
    return Container(
      width: 320, // Reduced from 410 for a more compact look
      margin: const EdgeInsets.only(right: 16, bottom: 16, top: 4),
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // Multi-layered shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFE60000).withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Content should fit or scroll internally if pushed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Reduced slightly
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE60000).withValues(alpha: 0.15),
                        const Color(0xFFE60000).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Color(0xFFE60000),
                    size: 20, // Reduced slightly
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.hospitalName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16, // Reduced slightly
                          letterSpacing: -0.5,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bank.name,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12, // Reduced slightly
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Reduced from 20
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LIVE INVENTORY',
                  style: TextStyle(
                    fontSize: 10, // Reduced slightly
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'UPDATED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced from 16
            // 2x4 Grid (4 Up 4 Down)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 6, // Reduced from 8
                childAspectRatio: 0.78, // Adjusted for smaller card width
              ),
              itemCount: bank.inventory.length,
              itemBuilder: (context, index) {
                final entry = bank.inventory.entries.elementAt(index);
                return _buildInventoryItem(context, ref, bank, entry.key, entry.value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, WidgetRef ref, BloodBankModel bank, String type, int quantity) {
    // Determine status color and fill
    final bool isLow = quantity < 5;
    final bool isEmpty = quantity == 0;
    
    // assuming 50 units is full for visualization
    final double fillLevel = (quantity / 25.0).clamp(0.1, 1.0);

    return GestureDetector(
      onTap: !isEmpty ? () => _showRequestDialog(context, ref, bank, type) : null,
      child: Column(
        children: [
          _BloodVial(
            fillLevel: fillLevel,
            isEmpty: isEmpty,
            color: isLow ? const Color(0xFFE60000) : const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 8),
          Text(
            type,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          Text(
            '$quantity Units',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: isLow ? const Color(0xFFE60000) : Colors.grey.shade500,
            ),
          ),
        ],
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

              final currentUnits = bank.inventory[type] ?? 0;
              final user = ref.read(firebaseAuthProvider).currentUser;
              final userProfile = ref.read(userProfileProvider).value;
              
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in first')),
                );
                return;
              }

              Navigator.pop(context); // Close dialog

              if (currentUnits == 0) {
                // Already out of stock, create emergency request
                final emergencyRequest = BloodRequest(
                  id: '',
                  patientName: name,
                  city: bank.location,
                  hospital: bank.hospitalName,
                  bloodType: type,
                  mobile: userProfile?.phone ?? '',
                  requesterId: user.uid,
                  status: 'pending',
                  createdAt: DateTime.now(),
                );

                try {
                  await ref
                      .read(emergencyNotificationServiceProvider)
                      .saveAndBroadcastEmergencyRequest(emergencyRequest);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bank out of stock. Emergency broadcast sent to donors!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to broadcast: $e')),
                    );
                  }
                }
                return;
              }

              try {

                final remainingUnits =
                    await ref.read(bloodBankRepositoryProvider).requestBlood(
                          bankId: bank.id,
                          bloodType: type,
                          units: 1,
                          patientName: name,
                          urgency: 'Emergency',
                          location: bank.location,
                          requesterId: user.uid,
                          mobile: userProfile?.phone ?? '',
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

  // Helper to calculate "Time Ago"
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} mins ago';
    return 'Just now';
  }

  /// The redesigned compact "Small Card" for emergency requests
  Widget _buildRequestCard(BuildContext context, WidgetRef ref, BloodRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade50, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🩸 Compact Blood Type Badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4D4D), Color(0xFFE60000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE60000).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                request.bloodType,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          // 👤 Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.patientName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  request.hospital,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(request.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // ⚡ Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleDonation(context, ref, request),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE60000).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Donate',
                  style: TextStyle(
                    color: Color(0xFFE60000),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDonation(BuildContext context, WidgetRef ref, BloodRequest request) {
    final userAsync = ref.read(userProfileProvider);
    userAsync.whenData((currentUser) {
      if (currentUser == null) return;

      final isCompatible = BloodCompatibility.canDonate(
        donorBloodType: currentUser.bloodType,
        receiverBloodType: request.bloodType,
      );

      if (isCompatible) {
        final pushService = ref.read(pushNotificationServiceProvider);
        final notificationRepo = ref.read(notificationRepositoryProvider);
        final donationRepo = ref.read(donationRepositoryProvider);
        final requestRepo = ref.read(requestRepositoryProvider);

        // In-app immediate alert for the donor
        pushService.showInAppNotification(
          title: 'Donation Accepted',
          body: 'You successfully signed up to donate ${request.bloodType} blood!',
        );

        // Save inbox notification for the receiver
        notificationRepo.createNotification(
          NotificationModel(
            id: '', // Firestore auto-generates ID
            userId: request.requesterId,
            title: 'Donor Found!',
            message: '${currentUser.name} has accepted your request for ${request.bloodType} blood.',
            isRead: false,
            createdAt: DateTime.now(),
            senderId: currentUser.uid,
            senderName: currentUser.name,
            type: 'donor_found',
            requestId: request.id,
          ),
        );

        // Save the donation transaction
        final donation = Donation(
          id: '',
          donorId: currentUser.uid,
          hospital: request.hospital,
          patientName: request.patientName,
          bloodType: request.bloodType,
          status: 'Accepted',
          donationDate: DateTime.now(),
        );

        donationRepo.createDonation(donation);

        // Remove the emergency request from the list
        requestRepo.deleteRequest(request.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you! You are donating to ${request.patientName}.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorry, your blood type (${currentUser.bloodType}) is not compatible.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }
}


class _BloodVial extends StatelessWidget {
  final double fillLevel;
  final bool isEmpty;
  final Color color;

  const _BloodVial({
    required this.fillLevel,
    required this.isEmpty,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, // Ultra small width
      height: 28, // Ultra small height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(6),
          bottom: Radius.circular(14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
          bottom: Radius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background (Empty vial state)
            Container(
              color: Colors.grey.shade50,
            ),
            // Liquid Fill with smooth animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut, // Elastic effect for "liquid" feel
              width: double.infinity,
              height: 28 * fillLevel,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.7),
                    color,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
            // White shine for glass effect
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                width: 1.5,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Top rim of liquid
            if (fillLevel > 0.05)
              Positioned(
                bottom: (28 * fillLevel) - 1.5,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
