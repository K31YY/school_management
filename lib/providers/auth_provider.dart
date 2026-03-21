import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final String? token;
  final String? role;
  final String? fullName;
  final bool isLoading;

  AuthState({
    this.token,
    this.role,
    this.fullName,
    this.isLoading = false,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    String? role,
    String? fullName,
    bool? isLoading,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('TOKEN');
    final role = prefs.getString('ROLE');
    final fullName = prefs.getString('FULLNAME');

    state = AuthState(
      token: token,
      role: role,
      fullName: fullName,
    );
  }

  Future<void> updateAuth({
    required String token,
    required String role,
    required String fullName,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('TOKEN', token);
    await prefs.setString('ROLE', role);
    await prefs.setString('FULLNAME', fullName);
    await prefs.setInt('USER_ID_KEY', userId);

    state = AuthState(
      token: token,
      role: role,
      fullName: fullName,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
