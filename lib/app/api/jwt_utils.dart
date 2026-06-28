import 'dart:convert';
import 'dart:typed_data';

/// Client-side JWT utilities for scheduling proactive refresh.
///
/// Decodes the JWT payload (base64url) WITHOUT verifying the signature —
/// the server is the authority on token validity. These helpers exist only
/// so the client can decide whether to refresh before expiry. Tampering
/// with `exp` client-side has no security impact: the server will reject
/// any invalid signature on the next request.
class JwtUtils {
  JwtUtils._();

  /// Decodes the JWT payload and returns the `exp` claim as a UTC DateTime,
  /// or `null` if the token is null/malformed/missing `exp`.
  static DateTime? getExpiry(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    String payload = parts[1];
    // Normalize base64url to base64: add padding, replace URL-safe chars.
    switch (payload.length % 4) {
      case 2:
        payload += '==';
        break;
      case 3:
        payload += '=';
        break;
      case 0:
        break;
      case 1:
        // Invalid base64 length — bail out.
        return null;
    }
    payload = payload.replaceAll('-', '+').replaceAll('_', '/');
    Uint8List decodedBytes;
    try {
      decodedBytes = base64.decode(payload);
    } catch (e) {
      return null;
    }
    String payloadJson;
    try {
      payloadJson = utf8.decode(decodedBytes);
    } catch (e) {
      return null;
    }
    dynamic payloadObj;
    try {
      payloadObj = jsonDecode(payloadJson);
    } catch (e) {
      return null;
    }
    if (payloadObj is! Map) return null;
    final exp = payloadObj['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  }

  /// Returns the remaining time until expiry. Returns `Duration.zero` if the
  /// token has already expired. Returns `null` if the token is unparseable.
  static Duration? remainingTime(String? token) {
    final exp = getExpiry(token);
    if (exp == null) return null;
    final remaining = exp.difference(DateTime.now().toUtc());
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }
}
