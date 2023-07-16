// All Api call will be here
import 'dart:convert';

import 'package:http/http.dart' as http;

class TodoServices {
  static Future<bool> deleteByID(String id) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  static Future<List?> fetchToDos() async {
    final url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final Response = await http.get(uri);
    if (Response.statusCode == 200) {
      final json = jsonDecode(Response.body) as Map;
      final result = json['items'] as List;
      return result;
    } else {
      return null;
    }
  }
}
