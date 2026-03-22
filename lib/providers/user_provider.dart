import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Rigorous State Object
class UserState {
  final String? token;
  final String? role;
  final bool isAuthenticated;
  final bool isLoading; // Added to handle the "Checking session" phase

  UserState({
    this.token,
    this.role,
    this.isAuthenticated = false,
    this.isLoading = false,
  });

  factory UserState.initial() => UserState();
  factory UserState.loading() => UserState(isLoading: true);
}

// 2. Optimized Logic (Notifier)
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState.initial()) {
    _loadStoredSession(); // Automatically check for saved login on startup
  }

  /// RESTORE SESSION: Loads token/role from device memory
  Future<void> _loadStoredSession() async {
    state = UserState.loading();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('TOKEN');
    final role = prefs.getString('ROLE');

    if (token != null && token.isNotEmpty) {
      state = UserState(token: token, role: role, isAuthenticated: true);
    } else {
      state = UserState.initial();
    }
  }

  /// UPDATE AUTH: Handles Login Success
  Future<void> updateAuth(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();

    // ANALYTICAL FIX: Normalize role to prevent "Stuck on Login" errors.
    // 'Teacher' (API) becomes 'teacher' (Flutter logic)
    final normalizedRole = role.trim().toLowerCase();

    // Persist data locally
    await prefs.setString('TOKEN', token);
    await prefs.setString('ROLE', normalizedRole);

    // CRITICAL FIX: Replace state entirely to trigger 'ref.watch' in main.dart
    state = UserState(
      token: token,
      role: normalizedRole,
      isAuthenticated: true,
    );
  }

  /// LOGOUT: Clears everything
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = UserState.initial();
  }
}

// 3. The Global Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
