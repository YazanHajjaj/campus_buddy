/// Contract for managing FCM tokens.
///
/// No Firebase or platform-specific logic lives here.
abstract class FcmTokenService {
  /// Save a new token for a user.
  Future<void> saveToken({
    required String uid,
    required String token,
    String? platform,
    String? appVersion,
  });

  /// Handle token refresh from Firebase.
  Future<void> refreshToken({
    required String uid,
    required String oldToken,
    required String newToken,
  });

  /// Remove a single invalid or unused token.
  Future<void> removeToken({
    required String uid,
    required String token,
  });

  /// Remove all tokens for a user.
  Future<void> removeAllTokens({
    required String uid,
  });
}