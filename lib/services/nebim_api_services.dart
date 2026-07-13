import '../supabase_service.dart';

class NebimApiService {
  static Future<Map<String, dynamic>> testConnection() async {
    final session = SupabaseService.client.auth.currentSession;

    if (session == null) {
      throw Exception('Aktif oturum bulunamadı.');
    }

    final response = await SupabaseService.client.functions.invoke(
      'nebim-api',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    return Map<String, dynamic>.from(data as Map);
  }
}
