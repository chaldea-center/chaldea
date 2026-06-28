// Form validators shared across the auth module. Ported verbatim from the
// legacy login_page.dart regexes so behavior stays identical.
// Why centralize: register / change-username / change-password / login pages
// all need the same rules; keeping them here prevents drift.

import 'package:chaldea/generated/l10n.dart';

/// Returns null if [name] is acceptable, else an error string.
/// Empty input returns null (caller decides whether empty is allowed).
String? validateUsername(String? name) {
  name ??= '';
  if (name.isEmpty) return null;
  if (RegExp(r'^\d+$').hasMatch(name)) {
    return 'number only name is not allowed';
  } else if (!RegExp(r'^[a-zA-Z0-9_]{4,18}$').hasMatch(name)) {
    return S.current.login_username_error;
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
  } else if (!RegExp(r'^[\x21-\x7e]{6,18}$').hasMatch(pwd)) {
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
