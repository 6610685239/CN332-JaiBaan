import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/financial_model.dart';

class FinancialService {
  String get apiUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<FinancialListResponse> getTransactions({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    int? month,
    int? year,
    String? category,
    String? token,
  }) async {
    try {
      final buffer = StringBuffer('${apiUrl}/financial/transactions?page=$page&limit=$limit');
      if (search != null && search.isNotEmpty) {
        buffer.write('&search=${Uri.encodeComponent(search)}');
      }
      if (type != null && type.isNotEmpty) {
        buffer.write('&type=${Uri.encodeComponent(type)}');
      }
      if (month != null && month > 0) {
        buffer.write('&month=$month');
      }
      if (year != null && year > 0) {
        buffer.write('&year=$year');
      }
      if (category != null && category.isNotEmpty) {
        buffer.write('&category=${Uri.encodeComponent(category)}');
      }

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(buffer.toString()), headers: headers);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return FinancialListResponse.fromJson(jsonBody);
      }
      throw Exception('Failed to load financial records: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching financial records: $e');
    }
  }

  Future<FinancialTransaction> getTransactionById(String id, {String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(
        Uri.parse('${apiUrl}/financial/transactions/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return FinancialTransaction.fromJson(jsonBody['data'] ?? {});
      }
      throw Exception('Failed to load transaction detail: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching transaction detail: $e');
    }
  }
}
