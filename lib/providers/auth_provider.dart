import 'package:web/web.dart' as web;
import 'package:uni_tech/models/User.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State that holds the current authenticated user (nullable initially)
class AuthState {
  final User? user;

  AuthState({this.user});

  AuthState copyWith({User? user}) {
    return AuthState(user: user ?? this.user);
  }
}

/// AuthNotifier to manage login/logout
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(user: null));

  /// Get currently authenticated user
  User? get authUser => state.user;

  /// Set the authenticated user
  void setAuth(User user) {
    state = state.copyWith(user: user);
  }

  User? getAuth() {
    return state.user;
  }

  /// Clear user (logout)
  void clearAuth() {
    state = AuthState(user: null);
    web.window.localStorage.clear();
  }
}

/// Global provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
