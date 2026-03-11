class BloodCompatibility {
  // Map of receiver -> list of compatible donors
  static const Map<String, List<String>> _compatibilityMatrix = {
    'A+': ['A+', 'A-', 'O+', 'O-'],
    'O+': ['O+', 'O-'],
    'B+': ['B+', 'B-', 'O+', 'O-'],
    'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // Universal receiver
    'A-': ['A-', 'O-'],
    'O-': ['O-'], // Universal donor (but can only receive O-)
    'B-': ['B-', 'O-'],
    'AB-': ['AB-', 'A-', 'B-', 'O-'],
  };

  /// Returns a boolean indicating if [donorBloodType] can safely donate to [receiverBloodType].
  static bool canDonate({required String donorBloodType, required String receiverBloodType}) {
    // Standardize input
    final donor = donorBloodType.trim().toUpperCase();
    final receiver = receiverBloodType.trim().toUpperCase();

    // If either blood type is invalid/unknown, reject the donation for safety
    if (!_compatibilityMatrix.containsKey(receiver) || !_compatibilityMatrix.containsKey(donor)) {
      return false;
    }

    final compatibleDonors = _compatibilityMatrix[receiver]!;
    return compatibleDonors.contains(donor);
  }

  /// Returns a list of blood types that the given [bloodType] can safely receive from.
  static List<String> canReceiveFrom(String bloodType) {
    final bt = bloodType.trim().toUpperCase();
    return _compatibilityMatrix[bt] ?? [];
  }

  /// Returns a list of blood types that the given [bloodType] can safely donate to.
  static List<String> canDonateTo(String donorBloodType) {
    final donor = donorBloodType.trim().toUpperCase();
    final List<String> receivers = [];
    _compatibilityMatrix.forEach((receiver, compatibleDonors) {
      if (compatibleDonors.contains(donor)) {
        receivers.add(receiver);
      }
    });
    return receivers;
  }
}
