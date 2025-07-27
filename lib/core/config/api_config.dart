/// Configuration for API endpoints
class ApiConfig {
  /// Base URL for the MediEvil Advisor backend API
  /// 
  /// IMPORTANT: Replace this with your own backend endpoint.
  /// The current URL is for personal prototyping only and will not work for other users.
  /// 
  /// Example for Firebase Cloud Functions:
  /// static const String baseUrl = 'https://us-central1-your-project.cloudfunctions.net';
  /// 
  /// Example for other serverless platforms:
  /// static const String baseUrl = 'https://your-api-gateway-url.com';
  /// 
  /// For local development:
  /// static const String baseUrl = 'http://localhost:5001/your-project/us-central1';
  static const String baseUrl = 'YOUR_BACKEND_URL_HERE'; // Replace with your own backend URL

  /// Task API endpoint
  static const String taskEndpoint = '/taskAPI';
  
  /// Audio API endpoint template
  static const String audioEndpointTemplate = '/audio/{sessionId}';

  /// Get the full task API URL
  static String get taskApiUrl => '$baseUrl$taskEndpoint';

  /// Get the full audio API URL for a session
  static String getAudioApiUrl(String sessionId) => '$baseUrl${audioEndpointTemplate.replaceAll('{sessionId}', sessionId)}';

  /// API request headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// Audio request headers
  static const Map<String, String> audioHeaders = {
    'Accept': 'audio/mpeg',
  };
} 