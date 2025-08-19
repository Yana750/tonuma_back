import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  final String baseUrl = 'http://192.168.0.20:8000'; // замени на свой IP

  Future<List<String>> fetchImageUrls() async {
    final response = await http.get(Uri.parse('$baseUrl/api/gallery/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map<String>((img) => '$baseUrl${img['image']}').toList();
    } else {
      throw Exception('Ошибка при загрузке изображений');
    }
  }
}
