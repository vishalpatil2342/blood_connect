import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:blood_connect/features/auth/presentation/screens/signin_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/edit_profile_screen.dart';
import 'package:blood_connect/features/patient/data/repositories/donor_repository.dart';
import 'package:blood_connect/core/models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    // 1. Watch the donations and requests providers
    final myDonationsAsync = ref.watch(myDonationsProvider);
    final myRequestsAsync = ref.watch(myRequestsProvider);

    // 2. Safely extract the count (default to 0 if loading or error)
    final donationsCount = myDonationsAsync.value?.length ?? 0;
    final requestsCount = myRequestsAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE60000))),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (user) {
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_circle_outlined,
                        size: 80,
                        color: Color(0xFFE60000),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Profile Not Found',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'We couldn\'t find your profile data. You might need to sign out and try again or contact support.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
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
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Profile Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: user.photoUrl.isNotEmpty
                          ? Image.network(
                              user.photoUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.person, color: Colors.grey, size: 50),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, color: Colors.grey, size: 50),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name and Location
                  Text(
                    user.name.isNotEmpty ? user.name : 'Unknown User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFFF2A5F),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location.isNotEmpty ? user.location : 'No Location Set',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatColumn('Blood Type', user.bloodType),
                      _buildDivider(),
                      _buildStatColumn('Donated', '${donationsCount.toString()} Times'), // Placeholder for now
                      _buildDivider(),
                      _buildStatColumn('Requested', '${requestsCount.toString()} Times'), // Placeholder for now
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Availability Switch
                  _buildToggleItem(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Available for Donate',
                    value: user.isAvailableForDonation,
                    onChanged: (val) async {
                      final updatedUser = UserModel(
                        uid: user.uid,
                        name: user.name,
                        email: user.email,
                        phone: user.phone,
                        bloodType: user.bloodType,
                        location: user.location,
                        photoUrl: user.photoUrl,
                        createdAt: user.createdAt,
                        authProvider: user.authProvider,
                        isAvailableForDonation: val,
                      );
                      await ref.read(donorRepositoryProvider).updateUserProfile(updatedUser);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Menu Items

                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    onTap: () => _handleLogout(context),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF2A5F),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: const Column(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE60000), size: 48),
            SizedBox(height: 16),
            Text(
              'Sign Out',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE60000),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(authControllerProvider.notifier).signOut();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
