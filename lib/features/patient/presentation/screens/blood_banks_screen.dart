import 'package:flutter/material.dart';

class BloodBanksScreen extends StatelessWidget {
  const BloodBanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for blood banks
    final List<Map<String, dynamic>> bloodBanks = [
      {
        'name': 'Red Cross Central',
        'location': 'Downtown Medical District',
        'inventory': {'A+': 12, 'B+': 8, 'O+': 24, 'AB+': 3, 'A-': 5, 'B-': 2, 'O-': 7, 'AB-': 1},
      },
      {
        'name': 'City General Hospital',
        'location': 'Northside',
        'inventory': {'A+': 5, 'B+': 15, 'O+': 10, 'AB+': 2, 'A-': 1, 'B-': 4, 'O-': 3, 'AB-': 0},
      },
      {
        'name': 'Community Blood Center',
        'location': 'Westend Suburbs',
        'inventory': {'A+': 20, 'B+': 10, 'O+': 30, 'AB+': 5, 'A-': 8, 'B-': 2, 'O-': 12, 'AB-': 2},
      },
    ];

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
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          itemCount: bloodBanks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final bank = bloodBanks[index];
            return _buildBloodBankCard(bank);
          },
        ),
      ),
    );
  }

  Widget _buildBloodBankCard(Map<String, dynamic> bank) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                    color: const Color(0xFFFF2A5F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Color(0xFFFF2A5F), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bank['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
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
                  'Available Units',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: (bank['inventory'] as Map<String, int>).entries.map((entry) {
                    return _buildBloodTypeBadge(entry.key, entry.value);
                  }).toList(),
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

  Widget _buildBloodTypeBadge(String type, int count) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: count > 0 ? const Color(0xFFFF2A5F).withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: count > 0 ? const Color(0xFFFF2A5F).withOpacity(0.2) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: count > 0 ? const Color(0xFFFF2A5F) : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: count > 0 ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
