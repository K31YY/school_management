import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 1. The State Model (Improved with copyWith)
class AuthState {
  final String? token;
  final String? role;
  final String? fullName;
  final int? userId;
  final bool isLoading;
  final bool isAuthenticated;

  AuthState({
    this.token,
    this.role,
    this.fullName,
    this.userId,
    this.isLoading = false,
    this.isAuthenticated = false,
  });

  // ANALYTICAL FIX: Added copyWith to update state safely
  AuthState copyWith({
    String? token,
    String? role,
    String? fullName,
    int? userId,
    bool? isLoading,
    bool? isAuthenticated,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  factory AuthState.initial() => AuthState();
}

/// 2. The Logic Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    // Set loading WITHOUT losing existing data structure
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('TOKEN');
      final role = prefs.getString('ROLE');
      final fullName = prefs.getString('FULLNAME');
      final userId = prefs.getInt('USER_ID_KEY');

      if (token != null && token.isNotEmpty && role != null) {
        state = AuthState(
          token: token,
          role: role.trim().toLowerCase(), // Ensure consistency
          fullName: fullName,
          userId: userId,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.initial();
    }
  }

  Future<void> updateAuth({
    required String token,
    required String role,
    required String fullName,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanRole = role.trim().toLowerCase();

    // 1. Persistence
    await prefs.setString('TOKEN', token);
    await prefs.setString('ROLE', cleanRole);
    await prefs.setString('FULLNAME', fullName);
    await prefs.setInt('USER_ID_KEY', userId);

    // 2. State Update (Triggers main.dart rebuild)
    state = AuthState(
      token: token,
      role: cleanRole,
      fullName: fullName,
      userId: userId,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState.initial();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
