import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.uid,
    super.email,
    super.phoneNumber,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
    super.isAnonymous,
  });

  factory AuthUserModel.fromFirebaseUser(User user) => AuthUserModel(
    uid: user.uid,
    email: user.email,
    phoneNumber: user.phoneNumber,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
    isAnonymous: user.isAnonymous,
  );

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final uid = json['uid'];
    if (uid is! String ||
        uid.isEmpty ||
        [
          'email',
          'phoneNumber',
          'displayName',
          'photoUrl',
        ].any((key) => json[key] != null && json[key] is! String) ||
        [
          'emailVerified',
          'isAnonymous',
        ].any((key) => json[key] != null && json[key] is! bool)) {
      throw const FormatException('Invalid cached auth user.');
    }
    return AuthUserModel(
      uid: uid,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'phoneNumber': phoneNumber,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'emailVerified': emailVerified,
    'isAnonymous': isAnonymous,
  };
}
