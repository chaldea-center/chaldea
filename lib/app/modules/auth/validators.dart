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
    return 'Username must be 4-18 characters long';
  }

  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
    return 'Username can only contain letters, digits, and underscores';
  }

  if (!RegExp(r'^[a-zA-Z]').hasMatch(name)) {
    return 'Username must start with a letter';
  }

  if (name.endsWith('_')) {
    return 'Username must not end with an underscore';
  }

  final lower = name.toLowerCase();
  if (_reservedNamePrefixes.any((prefix) => lower.startsWith(prefix))) {
    return 'This username is reserved';
  }
  if (_reservedNameExact.contains(lower)) {
    return 'This username is reserved';
  }

  return null;
}

/// Returns null if [email] is acceptable, else an error string.
String? validateEmail(String? email) {
  email ??= '';
  if (email.isEmpty) return null;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Invalid email address';
  }
  return null;
}

/// Returns null if [pwd] is acceptable, else an error string.
String? validatePassword(String? pwd) {
  pwd ??= '';
  if (pwd.isEmpty) return null;
  if (RegExp(r'^\d+$').hasMatch(pwd)) {
    return 'number only password is not allowed';
  } else if (!RegExp(r'^[\x20-\x7e]{6,18}$').hasMatch(pwd)) {
    return S.current.login_password_error;
  }
  return null;
}

/// Returns null if [newPwd] differs from [oldPwd] and is otherwise valid.
String? validateNewPassword(String? newPwd, {String? oldPwd}) {
  newPwd ??= '';
  if (newPwd.isEmpty) return null;
  if (oldPwd != null && oldPwd.isNotEmpty && newPwd == oldPwd) {
    return S.current.login_password_error_same_as_old;
  }
  return validatePassword(newPwd);
}

/// Returns null if [newName] differs from [oldName] and is otherwise valid.
String? validateNewName(String? newName, {String? oldName}) {
  newName ??= '';
  if (newName.isEmpty) return null;
  if (oldName != null && oldName.isNotEmpty && newName == oldName) {
    return 'Name not changed';
  }
  return validateUsername(newName);
}

/// Returns true if [name] + [pwd] together satisfy login preconditions.
bool isLoginAvailable(String name, String pwd) {
  return name.isNotEmpty && validateUsername(name) == null && pwd.isNotEmpty && validatePassword(pwd) == null;
}
