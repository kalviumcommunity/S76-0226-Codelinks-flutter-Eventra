import '../models/user_model.dart';

/// Singleton service to manage the current user session.
/// In production, this would integrate with Firebase Auth.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// Mock login — accepts any credentials.
  /// [role] determines admin vs student flow.
  void login({
    required String email,
    required String password,
    required UserRole role,
  }) {
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: role == UserRole.admin ? 'Admin User' : 'Student User',
      email: email.isNotEmpty ? email : 'user@college.edu',
      role: role,
      createdAt: DateTime.now(),
    );
  }

  /// Mock signup — creates a user and navigates back.
  void signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.isNotEmpty ? name : 'New User',
      email: email.isNotEmpty ? email : 'user@college.edu',
      role: role,
      createdAt: DateTime.now(),
    );
  }

  void logout() {
    _currentUser = null;
  }
}
