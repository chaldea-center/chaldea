// Server-side error codes returned in the `error_code` field of 401/4xx
// response details. Mirrors `backend/app/api/deps.py` ErrorCode enum.
//
// Kept as `static const String` (not a Dart enum) so that unknown codes
// added by future server releases fall through to `default` in switch
// statements instead of throwing.
class ApiErrorCode {
  ApiErrorCode._();

  // Auth / token
  static const String invalidCredentials = 'invalid_credentials';
  static const String tokenExpired = 'token_expired';
  static const String tokenRevoked = 'token_revoked';
  static const String tokenMissing = 'token_missing';

  // Permission
  static const String permissionDenied = 'permission_denied';

  // User
  static const String userNotFound = 'user_not_found';
  static const String userAlreadyExists = 'user_already_exists';
  static const String emailAlreadyExists = 'email_already_exists';

  // Verification codes
  static const String invalidVerificationCode = 'invalid_verification_code';
  static const String verificationCodeRateLimit = 'verification_code_rate_limit';

  // Voting
  static const String invalidVoteValue = 'invalid_vote_value';

  // Password reset
  static const String invalidResetToken = 'invalid_reset_token';
  static const String wrongCurrentPassword = 'wrong_current_password';
  static const String emailSameAsCurrent = 'email_same_as_current';

  // Resources
  static const String teamNotFound = 'team_not_found';
  static const String backupNotFound = 'backup_not_found';

  // Email binding
  static const String emailBindingRequired = 'email_binding_required';

  // Client version
  static const String versionTooLow = 'version_too_low';

  // Signed data
  static const String signDataNotAvailable = 'sign_data_not_available';

  // Recovery
  static const String accountLocked = 'account_locked'; // 429: per-username lockout on recover-by-device
  static const String adminRecoveryEmailTaken =
      'admin_recovery_email_taken'; // 409: admin recover email mode, email already bound
}
