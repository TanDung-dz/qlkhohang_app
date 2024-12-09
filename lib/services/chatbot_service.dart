import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Config/api_config.dart';

class ChatbotService {
  String get baseUrl => ApiConfig.baseUrl;
  final String _apiKey = 'sk-fkH9dNnFZIFBrz4m5PXhzNSzlJte2idIx4na14ig4jDV8vBl';  // Your API Key

  // Function to get chatbot response
  Future<String> getChatbotResponse(String userMessage) async {
    final url = Uri.parse('https://api.yescale.io/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',  // API Key for Authorization
    };

    final body = jsonEncode({
      'model': 'claude-3-sonnet-20240229',  // Model you want to use (Update to match what you need)
      'messages': [
        {'role': 'user', 'content': userMessage},  // User's message
      ],
      'max_tokens': 4000,  // Maximum tokens (you can adjust this based on needs)
      'temperature': 0.2,  // Temperature setting for the model
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safely handle response data
        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final message = data['choices'][0]['message']['content'];
          return message ?? 'No response content available';
        } else {
          return 'No choices in the response';
        }
      } else {
        return 'Failed to get response, status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
