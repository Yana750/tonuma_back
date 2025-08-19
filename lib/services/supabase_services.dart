import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<String>> fetchSliderImages() async {
  final response = await Supabase.instance.client
      .storage
      .from('sliders')
      .list();

  if (response.isEmpty) {
    return [];
  }

  // Маппинг файлов в публичные ссылки
  return response.map((file) {
    return Supabase.instance.client.storage
        .from('sliders')
        .getPublicUrl(file.name);
  }).toList();
}

