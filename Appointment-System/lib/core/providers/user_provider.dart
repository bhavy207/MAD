import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Hardcoded Admin Credentials ──────────────────────────────────────────────
const _adminEmail = 'admin@smartqueue.com';
const _adminPassword = 'admin123';
const _adminName = 'Administrator';

// ── User Roles ────────────────────────────────────────────────────────────────
enum UserRole { user, admin, guest }

// ── Login Result (specific error codes) ──────────────────────────────────────
enum LoginResult {
  success,
  noAccountFound,   // No account registered at all
  wrongPassword,    // Account found but password mismatch
}

// ── UserModel ─────────────────────────────────────────────────────────────────
class UserModel {
  final String name;
  final String email;
  final String password;
  final bool isLoggedIn;
  final UserRole role;

  const UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.isLoggedIn,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isGuest => role == UserRole.guest;

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    bool? isLoggedIn,
    UserRole? role,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
    );
  }

  static const empty = UserModel(
    name: '',
    email: '',
    password: '',
    isLoggedIn: false,
    role: UserRole.guest,
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────
final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(UserModel.empty) {
    _loadUser();
  }

  Box get _box => Hive.box('settings');

  void _loadUser() {
    final name = _box.get('user_name', defaultValue: '') as String;
    final email = _box.get('user_email', defaultValue: '') as String;
    final password = _box.get('user_password', defaultValue: '') as String;
    final isLoggedIn = _box.get('is_logged_in', defaultValue: false) as bool;
    final roleStr = _box.get('user_role', defaultValue: 'user') as String;
    final role = roleStr == 'admin' ? UserRole.admin : UserRole.user;

    state = UserModel(
      name: name,
      email: email,
      password: password,
      isLoggedIn: isLoggedIn,
      role: role,
    );
  }

  // ── Check if any account is registered ───────────────────────────────────
  bool get hasRegisteredAccount {
    final storedPassword = _box.get('user_password', defaultValue: '') as String;
    return storedPassword.isNotEmpty;
  }

  // ── Sign Up (always creates a regular user) ──────────────────────────────
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _box.put('user_name', name.trim());
    await _box.put('user_email', email.trim());
    await _box.put('user_password', password);
    await _box.put('is_logged_in', true);
    await _box.put('user_role', 'user');
    state = UserModel(
      name: name.trim(),
      email: email.trim(),
      password: password,
      isLoggedIn: true,
      role: UserRole.user,
    );
  }

  // ── Login — returns a specific LoginResult ────────────────────────────────
  Future<LoginResult> login({
    required String emailOrName,
    required String password,
  }) async {
    final input = emailOrName.trim().toLowerCase();
    final inputPassword = password; // passwords are case-sensitive

    // 1. Check hardcoded admin account
    if (input == _adminEmail.toLowerCase() && inputPassword == _adminPassword) {
      await _box.put('user_name', _adminName);
      await _box.put('user_email', _adminEmail);
      await _box.put('user_password', _adminPassword);
      await _box.put('is_logged_in', true);
      await _box.put('user_role', 'admin');
      state = const UserModel(
        name: _adminName,
        email: _adminEmail,
        password: _adminPassword,
        isLoggedIn: true,
        role: UserRole.admin,
      );
      return LoginResult.success;
    }

    // 2. Read stored user data
    final storedEmail    = (_box.get('user_email',    defaultValue: '') as String).trim().toLowerCase();
    final storedName     = (_box.get('user_name',     defaultValue: '') as String).trim().toLowerCase();
    final storedPassword = (_box.get('user_password', defaultValue: '') as String);
    final storedRoleStr  = (_box.get('user_role',     defaultValue: 'user') as String);

    // 3. No account registered yet
    if (storedPassword.isEmpty && storedEmail.isEmpty && storedName.isEmpty) {
      return LoginResult.noAccountFound;
    }

    // 4. Check if identifier matches (name OR email OR mobile number)
    final identifierMatch = (storedEmail == input) || (storedName == input);
    if (!identifierMatch) {
      // Could be no account OR simply not found — treat as no account
      return LoginResult.noAccountFound;
    }

    // 5. Identifier matched — now check password
    if (storedPassword != inputPassword) {
      return LoginResult.wrongPassword;
    }

    // 6. Full match — log in
    await _box.put('is_logged_in', true);
    state = UserModel(
      name: _box.get('user_name', defaultValue: '') as String,
      email: _box.get('user_email', defaultValue: '') as String,
      password: storedPassword,
      isLoggedIn: true,
      role: storedRoleStr == 'admin' ? UserRole.admin : UserRole.user,
    );
    return LoginResult.success;
  }

  // ── Update Name ───────────────────────────────────────────────────────────
  Future<void> updateName(String newName) async {
    await _box.put('user_name', newName.trim());
    state = state.copyWith(name: newName.trim());
  }

  // ── Change Password ───────────────────────────────────────────────────────
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final storedPassword = _box.get('user_password', defaultValue: '') as String;
    if (storedPassword == currentPassword) {
      await _box.put('user_password', newPassword);
      state = state.copyWith(password: newPassword);
      return true;
    }
    return false;
  }

  // ── Clear stored user data (for re-registration) ──────────────────────────
  Future<void> clearAccount() async {
    await _box.delete('user_name');
    await _box.delete('user_email');
    await _box.delete('user_password');
    await _box.delete('user_role');
    await _box.put('is_logged_in', false);
    state = UserModel.empty;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _box.put('is_logged_in', false);
    state = state.copyWith(isLoggedIn: false, role: UserRole.guest);
  }
}
