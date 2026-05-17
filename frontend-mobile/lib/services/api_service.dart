import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/facility_model.dart';
import '../models/reservation_model.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/api"; 

  Future<List<Facility>> getFacilities() async {
    final response = await http.get(Uri.parse('$baseUrl/facilities'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Facility.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load facilities');
    }
  }

  Future<Map<String, dynamic>> bookFacility(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/facilities/book'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bookingData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to book facility: ${response.body}');
    }
  }

  Future<List<Reservation>> getMyBookings(int residentId) async {
    final response = await http.get(Uri.parse('$baseUrl/facilities/my-bookings/$residentId'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Reservation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<void> deleteBooking(int bookingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/facilities/reservations/$bookingId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete booking: ${response.body}');
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/facilities/reservations/$bookingId/cancel'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getFacilityBookings(int facilityId, String date) async {
    final response = await http.get(Uri.parse('$baseUrl/facilities/$facilityId/bookings?date=$date'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load availability');
    }
  }
}