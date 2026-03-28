##lib/services/auth_service.dart

  import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  // Registro
  Future<void> registrar(String email, String password) async {
    await _auth.signUp(email: email, password: password);
  }

  // Login
  Future<void> login(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // Stream de cambios de sesión
  Stream<AuthState> get sesionStream => _auth.onAuthStateChange;
}
