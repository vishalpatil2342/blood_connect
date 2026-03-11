class BloodBankModel {
  final String id;
  final String name;
  final String location;
  final Map<String, int> inventory;

  BloodBankModel({
    required this.id,
    required this.name,
    required this.location,
    required this.inventory,
  });

  factory BloodBankModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodBankModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      inventory: map['inventory'] != null
          ? Map<String, int>.from(map['inventory'])
          : {'A+': 0, 'B+': 0, 'O+': 0, 'AB+': 0, 'A-': 0, 'B-': 0, 'O-': 0, 'AB-': 0},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'inventory': inventory,
    };
  }
}
