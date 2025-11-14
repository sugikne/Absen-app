import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/absensi_request.dart';

class AbsensiService {
  final String url =
      'https://absensi-mobile.primakarauniversity.ac.id/api/absensi';

  /// Submits the absensi request and returns decoded JSON on success.
  /// Throws an [Exception] when the HTTP call fails.
  Future<Map<String, dynamic>> submitAbsensi(AbsensiRequest data) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    // Provide useful error information for debugging.
    throw Exception(
      'Failed to submit absensi (status: ${response.statusCode}): ${response.body}',
    );
  }
}
