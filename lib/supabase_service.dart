import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://rpnxtldxrvolndguhdgb.supabase.co';

  static const String supabaseAnonKey =
      'sb_publishable_6oeVYYPtD4R90jRIjq4PCg_2Vgs0qk6';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
