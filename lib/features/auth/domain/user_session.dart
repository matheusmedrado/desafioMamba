/// Signed-in user as stored on the device.
///
/// Authentication is local only. The email identifies the user and
/// [signedInAt] records when the session started. No password is kept.
class UserSession {
  const UserSession({required this.email, required this.signedInAt});

  final String email;
  final DateTime signedInAt;

  Map<String, Object> toJson() => {
    'email': email,
    'signedInAt': signedInAt.toUtc().millisecondsSinceEpoch,
  };

  factory UserSession.fromJson(Map<String, Object?> json) {
    return UserSession(
      email: json['email']! as String,
      signedInAt: DateTime.fromMillisecondsSinceEpoch(
        json['signedInAt']! as int,
        isUtc: true,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserSession &&
      other.email == email &&
      other.signedInAt == signedInAt;

  @override
  int get hashCode => Object.hash(email, signedInAt);
}
