import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
        url:"https://example.supabase.co",
        anonKey: "ANON_KEY_SUPABASE");
  }

  static SupabaseClient get client => Supabase.instance.client;
}