class Facility {
  final int id;
  final String name;
  final String? imageUrl;
  final int? capacityMin;
  final int? capacityMax;
  final String? openTime;
  final String? closeTime;
  final String? description;

  Facility({
    required this.id,
    required this.name,
    this.imageUrl,
    this.capacityMin,
    this.capacityMax,
    this.openTime,
    this.closeTime,
    this.description,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      capacityMin: json['capacityMin'],
      capacityMax: json['capacityMax'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      description: json['description'],
    );
  }
}