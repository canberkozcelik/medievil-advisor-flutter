import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';

/// Abstract remote data source for assistant API
abstract class AssistantRemoteDataSource {
  Future<Map<String, dynamic>> sendTask(String task);
  Future<Uint8List> getAudioStream(String sessionId);
}

/// Implementation of AssistantRemoteDataSource
class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {

  @override
  Future<Map<String, dynamic>> sendTask(String task) async {
    try {
      print('Sending task to API: $task');
      final response = await http.post(
        Uri.parse(ApiConfig.taskApiUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'task': task}),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Headers: ${response.headers}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final result = {
            'result': data['result'] as String,
            'audioSessionId': data['audioSessionId'] as String,
            'audioUrl': data['audioUrl'] as String,
          };
          print('Parsed API Response: $result');
          return result;
        } catch (parseError) {
          print('Failed to parse API response: $parseError');
          print('Raw response body: ${response.body}');
          throw Exception('Invalid API response format: $parseError');
        }
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 'Unknown server error';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }

        print('API Error: $errorMessage');
        print('Error Status: ${response.statusCode}');
        print('Error Headers: ${response.headers}');
        print('Error Body: ${response.body}');

        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Uint8List> getAudioStream(String sessionId) async {
    try {
      final audioUrl = ApiConfig.getAudioApiUrl(sessionId);
      print('Fetching audio from: $audioUrl');

      final response = await http.get(
        Uri.parse(audioUrl),
        headers: ApiConfig.audioHeaders,
      );

      print('Audio Response Status: ${response.statusCode}');
      print('Audio Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('Audio fetched successfully, size: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? 'Unknown audio error';
        } catch (e) {
          errorMessage = 'Audio error: ${response.statusCode}';
        }

        print('Audio Error: $errorMessage');
        print('Audio Error Status: ${response.statusCode}');
        print('Audio Error Headers: ${response.headers}');
        print('Audio Error Body: ${response.body}');

        if (response.statusCode == 404) {
          throw Exception('Audio session not found or expired: $errorMessage');
        } else {
          throw Exception('Audio fetch failed: $errorMessage');
        }
      }
    } catch (e) {
      print('Audio fetch error: $e');
      throw Exception('Audio fetch error: $e');
    }
  }
} 