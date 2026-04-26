import 'facility_model.dart';

class Reservation {
  final int id;
  final String bookingCode;
  final int residentId;
  final int facilityId;
  final DateTime startTime;
  final DateTime endTime;
  final int pax;
  final String status;
  final String? note;
  final DateTime createdAt;
  final Facility? facility;

  Reservation({
    required this.id,
    required this.bookingCode,
    required this.residentId,
    required this.facilityId,
    required this.startTime,
    required this.endTime,
    required this.pax,
    required this.status,
    this.note,
    required this.createdAt,
    this.facility,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      bookingCode: json['bookingCode'],
      residentId: json['residentId'],
      facilityId: json['facilityId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      pax: json['pax'],
      status: json['status'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      facility: json['facility'] != null ? Facility.fromJson(json['facility']) : null,
    );
  }
}
