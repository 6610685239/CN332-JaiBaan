// lib/services/announcement_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _readStatusKey = 'announcement_read_status'; // Local storage key

  String get apiUrl {
    // ถ้าเป็น Web หรือรันบนคอม (Linux/Windows/Mac) ให้ใช้ localhost
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api';
    }

    // ถ้าเป็น Android (Emulator) ให้ใช้ 10.0.2.2
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }

    // กรณีอื่นๆ (เช่น iOS Simulator)
    return 'http://localhost:3000/api';
  }

  // Get announcements with pagination, search, and filter
  Future<AnnouncementListResponse> getAnnouncements({
    String? category,
    String? search,
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    try {
      String url = '${apiUrl}/announcements?page=$page&limit=$limit&status=PUBLISHED';

      if (category != null && category.isNotEmpty && category != 'ALL') {
        url += '&category=$category';
      }

      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return AnnouncementListResponse.fromJson(json);
      } else {
        throw Exception('Failed to load announcements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }

  // Get single announcement detail
  Future<Announcement> getAnnouncementDetail(String id, {String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('${apiUrl}/announcements/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Announcement.fromJson(json['data'] ?? {});
      } else {
        throw Exception('Failed to load announcement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching announcement detail: $e');
    }
  }

  // Local storage: Mark announcement as read
  Future<void> markAsRead(String announcementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIdsJson = prefs.getString(_readStatusKey) ?? '[]';
      final readIds = List<String>.from(jsonDecode(readIdsJson));
      if (!readIds.contains(announcementId)) {
        readIds.add(announcementId);
        await prefs.setString(_readStatusKey, jsonEncode(readIds));
      }
    } catch (e) {
      // Silently fail if local storage fails
      print('Error marking announcement as read: $e');
    }
  }

  // Local storage: Check if announcement is read
  Future<bool> isRead(String announcementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIdsJson = prefs.getString(_readStatusKey) ?? '[]';
      final readIds = List<String>.from(jsonDecode(readIdsJson));
      return readIds.contains(announcementId);
    } catch (e) {
      return false;
    }
  }

  // Local storage: Get all read announcement IDs
  Future<Set<String>> getAllReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIdsJson = prefs.getString(_readStatusKey) ?? '[]';
      final readIds = List<String>.from(jsonDecode(readIdsJson));
      return readIds.toSet();
    } catch (e) {
      return {};
    }
  }

  // Local storage: Clear read status (for testing or user preference)
  Future<void> clearReadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_readStatusKey);
    } catch (e) {
      print('Error clearing read status: $e');
    }
  }
}
