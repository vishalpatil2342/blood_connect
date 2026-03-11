import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE60000), // Primary Red
          iconTheme: const IconThemeData(color: Colors.white), // Makes back button white if present
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Activity',
            style: TextStyle(
              color: Colors.white, // White text
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
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
        body: const TabBarView(
          children: [
            // Donations Tab
            _DonationsList(),
            
            // Requests Tab
            _RequestsList(),
          ],
        ),
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
              title: 'Donated to ${donation.hospital}',
              date: _formatDate(donation.donationDate),
              bloodType: donation.bloodType,
              status: donation.status.toUpperCase(),
              statusColor: donation.status.toLowerCase() == 'completed' ? Colors.green : Colors.orange,
              icon: Icons.volunteer_activism_outlined,
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
              title: request.hospital,
              date: _formatDate(request.createdAt),
              bloodType: request.bloodType,
              status: request.status.toUpperCase(),
              statusColor: request.status.toLowerCase() == 'pending' ? Colors.orange : Colors.green,
              icon: Icons.bloodtype_outlined,
            );
          },
        );
      },
    );
  }
}

Widget _buildActivityCard({
  required String title,
  required String date,
  required String bloodType,
  required String status,
  required Color statusColor,
  required IconData icon,
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
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
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
          ],
        ),
      ],
    ),
  );
}
