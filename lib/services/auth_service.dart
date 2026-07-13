import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../supabase_service.dart';

class AuthService {
  static const String _loginDomain = 'ltbstok.local';

  static String _emailForUserCode(String userCode) {
    return '${userCode.trim().toLowerCase()}@$_loginDomain';
  }

  static Session? get currentSession =>
      SupabaseService.client.auth.currentSession;

  static Future<AppUser> signIn({
    required String userCode,
    required String password,
  }) async {
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: _emailForUserCode(userCode),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Oturum oluşturulamadı.');
    }

    return getCurrentProfile();
  }

  static Future<AppUser> getCurrentProfile() async {
    final user = SupabaseService.client.auth.currentUser;

    if (user == null) {
      throw const AuthException('Aktif oturum bulunamadı.');
    }

    final result = await SupabaseService.client
        .from('profiles')
        .select('id, kullanici_kodu, rol, magaza')
        .eq('id', user.id)
        .single();

    return AppUser.fromMap(result);
  }

  static Future<void> changePassword(String newPassword) async {
    await SupabaseService.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  static Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }
}
