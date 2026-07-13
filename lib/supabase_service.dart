import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://rpnxtldxrvolndguhdgb.supabase.co';

  static const String supabasePublishableKey =
      'sb_publishable_6oeVYYPtD4R90jRIjq4PCg_2Vgs0qk6';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
