import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiChatService {
  final String _apiKey = 'AIzaSyAgEZr2HgqeieWLDWwOHbIykDa-paxyJuY'; // Replace with your actual key

  Future<String> sendMessage(String message) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey',
    );

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": message}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
      } else {
        return 'API Error: ${response.statusCode} ${response.reasonPhrase}\n${response.body}';
      }
    } catch (e) {
      return 'Communication error: $e';
    }
  }
}
