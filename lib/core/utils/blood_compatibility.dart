class BloodCompatibility {
  /// Returns a boolean indicating if [donorBloodType] can safely donate to [receiverBloodType].
  static bool canDonate({required String donorBloodType, required String receiverBloodType}) {
    // Standardize input
    final donor = donorBloodType.trim().toUpperCase();
    final receiver = receiverBloodType.trim().toUpperCase();

    // Map of receiver -> list of compatible donors
    final Map<String, List<String>> compatibilityMatrix = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'O+': ['O+', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // Universal receiver
      'A-': ['A-', 'O-'],
      'O-': ['O-'], // Universal donor (but can only receive O-)
      'B-': ['B-', 'O-'],
      'AB-': ['AB-', 'A-', 'B-', 'O-'],
    };

    // If either blood type is invalid/unknown, reject the donation for safety
    if (!compatibilityMatrix.containsKey(receiver) || !compatibilityMatrix.containsKey(donor)) {
      return false;
    }

    final compatibleDonors = compatibilityMatrix[receiver]!;
    return compatibleDonors.contains(donor);
  }
}
