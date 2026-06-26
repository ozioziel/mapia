class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.username,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.phoneVerified = false,
  });

  final String id;
  final String email;
  final String role;
  final String username;
  final String name;
  final String firstName;
  final String lastName;
  final String? phone;
  final bool phoneVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
    );
  }
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;
}

class AuthResponse {
  const AuthResponse({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }
}
