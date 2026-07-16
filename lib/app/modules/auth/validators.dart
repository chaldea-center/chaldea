// Form validators shared across the auth module. Ported verbatim from the
// legacy login_page.dart regexes so behavior stays identical.
// Why centralize: register / change-username / change-password / login pages
// all need the same rules; keeping them here prevents drift.

import 'package:chaldea/generated/l10n.dart';

const _reservedNamePrefixes = <String>[
  //
  'admin', 'root', 'superuser', 'sysadmin',
  'moderator', 'webmaster', 'helpdesk',
  'security', 'abuse', 'legal',
  'chaldea', 'laplace',
];

const _reservedNameExact = <String>[
  //
  'administrator', 'mod', 'staff', 'team', 'official',
  'support', 'help', 'service', 'contact',
  'safety', 'trust', 'demo',
  'system', 'null', 'undefined', 'nobody', 'anonymous',
  'guest', 'test', 'noreply',
];

/// Returns null if [name] is acceptable, else an error string.
/// Empty input returns null (caller decides whether empty is allowed).
///
/// Rules:
/// 1. 4-18 characters
/// 2. Only ASCII letters, digits, and underscores
/// 3. Must start with a letter (not a digit or underscore)
/// 4. Must not end with an underscore
/// 5. Must not start with a prefix-restricted keyword (blocks variants)
/// 6. Must not exactly match an exact-restricted keyword
String? validateUsername(String? name) {
  name ??= '';
  if (name.isEmpty) return null;

  if (name.length < 4 || name.length > 18) {
    return S.current.validation_username_length;
  }

  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
    return S.current.validation_username_format;
  }

  if (!RegExp(r'^[a-zA-Z]').hasMatch(name)) {
    return S.current.validation_username_start_letter;
  }

  if (name.endsWith('_')) {
    return S.current.validation_username_end_no_underscore;
  }

  final lower = name.toLowerCase();
  if (_reservedNamePrefixes.any((prefix) => lower.startsWith(prefix))) {
    return S.current.validation_username_reserved;
  }
  if (_reservedNameExact.contains(lower)) {
    return S.current.validation_username_reserved;
  }

  return null;
}

/// Returns null if [email] is acceptable, else an error string.
String? validateEmail(String? email) {
  email ??= '';
  if (email.isEmpty) return null;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return S.current.validation_email_invalid;
  }
  return null;
}

/// Returns null if [pwd] is acceptable, else an error string.
String? validatePassword(String? pwd) {
  pwd ??= '';
  if (pwd.isEmpty) return null;
  if (RegExp(r'^\d+$').hasMatch(pwd)) {
    return S.current.validation_password_not_all_digits;
  }
  if (pwd.length < 6 || pwd.length > 18) {
    return S.current.validation_password_length;
  }
  if (!RegExp(r'^[\x20-\x7e]+$').hasMatch(pwd)) {
    return S.current.validation_password_format;
  }
  return null;
}

/// Returns null if [newPwd] differs from [oldPwd] and is otherwise valid.
String? validateNewPassword(String? newPwd, {String? oldPwd}) {
  newPwd ??= '';
  if (newPwd.isEmpty) return null;
  if (oldPwd != null && oldPwd.isNotEmpty && newPwd == oldPwd) {
    return S.current.validation_password_same_as_old;
  }
  return validatePassword(newPwd);
}

/// Returns null if [newName] differs from [oldName] and is otherwise valid.
String? validateNewName(String? newName, {String? oldName}) {
  newName ??= '';
  if (newName.isEmpty) return null;
  if (oldName != null && oldName.isNotEmpty && newName == oldName) {
    return S.current.validation_name_same_as_old;
  }
  return validateUsername(newName);
}

/// Login identifier: accepts both username and email.
/// Only checks non-empty, reasonable length, and no whitespace/control chars.
/// Format validation deferred to server.
String? validateLoginIdentifier(String value) {
  if (value.isEmpty) return S.current.validation_required;
  if (value.length > 254) return S.current.validation_too_long;
  // Reject whitespace and control characters
  if (RegExp(r'[\s\x00-\x1f\x7f]').hasMatch(value)) {
    return S.current.validation_no_whitespace;
  }
  return null;
}

/// Returns true if [name] + [pwd] together satisfy login preconditions.
bool isLoginAvailable(String name, String pwd) {
  return validateLoginIdentifier(name) == null && pwd.isNotEmpty && validatePassword(pwd) == null;
}
