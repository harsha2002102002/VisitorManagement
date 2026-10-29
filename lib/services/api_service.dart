import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/visitor.dart';

class VisitorService {
  static const String baseUrl =
      'https://6ae0d1f6be3bc8fead97f727.mockapi.io';

  final http.Client _client;
  VisitorService({http.Client? client})
      : _client = client ?? http.Client();

  Future<VisitorModel> registerVisitor(
      VisitorModel visitor,
      ) async {
    final uri = Uri.parse('$baseUrl/sendVisitorDetails');

    final response = await _client
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(visitor.toJson()),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'Unexpected API response format',
        );
      }

      return VisitorModel.fromJson(data);
    }

    throw Exception(
      'Registration failed (${response.statusCode}): '
          '${response.body}',
    );
  }

  Future<List<VisitorModel>> getVisitors() async {
    final response = await _client
        .get(
      Uri.parse('$baseUrl/sendVisitorDetails'),
      headers: {'Accept': 'application/json'},
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load visitors: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => VisitorModel.fromJson(
      item as Map<String, dynamic>,
    ))
        .toList();
  }

  Future<VisitorModel> updateVisitStatus({
    required String visitorId,
    required String status,
    required String? checkInTime,
    required String? checkOutTime,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/sendVisitorDetails/${Uri.encodeComponent(visitorId)}',
    );
    final response = await _client
        .patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
      }),
    )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return VisitorModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      'Failed to update visit status: ${response.statusCode}',
    );
  }

  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    if (visitor.id == null || visitor.id!.isEmpty) {
      throw Exception('Visitor ID is missing');
    }

    final response = await _client
        .put(
      Uri.parse('$baseUrl/sendVisitorDetails/${visitor.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visitor.toJson()),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to update visitor: ${response.statusCode}');
    }

    return VisitorModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<VisitorModel> getVisitorById(String id) async {
    final uri = Uri.parse(
      '$baseUrl/sendVisitorDetails/${Uri.encodeComponent(id)}',
    );

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VisitorModel.fromJson(
        data as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Visitor not found');
    }

    throw Exception(
      'Failed to fetch visitor (${response.statusCode})',
    );
  }

  Future<void> deleteVisitor(String id) async {
    final response = await _client
        .delete(
      Uri.parse('$baseUrl/sendVisitorDetails/$id'),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception('Failed to delete visitor: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
