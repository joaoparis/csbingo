import 'package:uuid/uuid.dart';

class UserService {
  static UserService? _instance;
  late String _userId;
  String _nickname = '';

  UserService._internal() {
    // Generate UUID once on initialization
    _userId = const Uuid().v4();
  }

  /// Get singleton instance
  static UserService getInstance() {
    _instance ??= UserService._internal();
    return _instance!;
  }

  /// Get user ID (UUID)
  String get id => _userId;

  /// Get current nickname
  String get nickname => _nickname;

  /// Set nickname
  void setNickname(String value) {
    _nickname = value.trim();
  }

  /// Reset for testing
  static void reset() {
    _instance = null;
  }
}
