class BloodBankModel {
  final String id;
  final String name;
  final String hospitalName;
  final String location;
  final Map<String, int> inventory;

  BloodBankModel({
    required this.id,
    required this.name,
    required this.hospitalName,
    required this.location,
    required this.inventory,
  });

  factory BloodBankModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodBankModel(
      id: id,
      name: map['name'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      location: map['location'] ?? '',
      inventory: map['inventory'] != null
          ? (map['inventory'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toInt()),
            )
          : {
              'A+': 0,
              'B+': 0,
              'O+': 0,
              'AB+': 0,
              'A-': 0,
              'B-': 0,
              'O-': 0,
              'AB-': 0
            },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hospitalName': hospitalName,
      'location': location,
      'inventory': inventory,
    };
  }
}
