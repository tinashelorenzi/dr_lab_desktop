
import 'user.dart';

class LoginResult {
  final User user;
  final String token;
  final bool needsSetup;

  LoginResult({
    required this.user,
    required this.token,
    required this.needsSetup,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      user: User.fromJson(json['user']),
      token: json['token'] as String,
      needsSetup: json['needs_setup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'needs_setup': needsSetup,
    };
  }

  @override
  String toString() {
    return 'LoginResult(user: ${user.fullName}, token: ${token.substring(0, 10)}..., needsSetup: $needsSetup)';
  }
}