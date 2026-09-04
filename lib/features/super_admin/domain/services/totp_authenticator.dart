import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// RFC 6238 standard Time-based One-Time Password (TOTP) engine.
///
/// Compatible with Google Authenticator, Authy, Microsoft Authenticator,
/// and 1Password. Uses standard HMAC-SHA1 dynamic truncation.
class TotpAuthenticator {
  TotpAuthenticator._();

  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Decodes a Base32 string into raw bytes per RFC 4648.
  static Uint8List base32Decode(String input) {
    final cleaned = input.toUpperCase().replaceAll('=', '').replaceAll(' ', '');
    final output = <int>[];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      final val = _base32Chars.indexOf(char);
      if (val == -1) continue;
      buffer = (buffer << 5) | val;
      bitsLeft += 5;
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        output.add((buffer >> bitsLeft) & 0xff);
      }
    }
    return Uint8List.fromList(output);
  }

  /// Generates a standard 6-digit TOTP code for the given Base32 secret at the given [time].
  static String generateCode(
    String secretBase32, {
    DateTime? time,
    int stepSeconds = 30,
    int digits = 6,
  }) {
    final now = time ?? DateTime.now();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final counter = epochSeconds ~/ stepSeconds;

    final key = base32Decode(secretBase32);
    final counterBytes = Uint8List(8);
    var tempCounter = counter;
    for (int i = 7; i >= 0; i--) {
      counterBytes[i] = tempCounter & 0xff;
      tempCounter >>= 8;
    }

    final hmac = Hmac(sha1, key);
    final hash = hmac.convert(counterBytes).bytes;

    final offset = hash[hash.length - 1] & 0x0f;
    final binaryCode = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    final otp = binaryCode % 1000000;
    return otp.toString().padLeft(digits, '0');
  }

  /// Verifies a TOTP code against the secret key with clock-drift window tolerance.
  ///
  /// A [window] of 1 checks the current 30-second interval, plus 1 interval before
  /// and 1 interval after (±30 seconds tolerance) to accommodate device clock skew.
  static bool verifyCode(
    String secretBase32,
    String code, {
    DateTime? time,
    int window = 1,
  }) {
    final now = time ?? DateTime.now();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final currentStep = epochSeconds ~/ 30;

    final normalizedCode = code.trim().replaceAll(' ', '');
    if (normalizedCode.length != 6) return false;

    for (int i = -window; i <= window; i++) {
      final stepTime = DateTime.fromMillisecondsSinceEpoch((currentStep + i) * 30 * 1000);
      final expected = generateCode(secretBase32, time: stepTime);
      if (expected == normalizedCode) {
        return true;
      }
    }
    return false;
  }

  /// Generates a standard `otpauth://` URI that can be scanned by Authenticator apps.
  static String generateOtpAuthUri({
    required String accountName,
    required String issuer,
    required String secretBase32,
  }) {
    final encodedIssuer = Uri.encodeComponent(issuer);
    final encodedAccount = Uri.encodeComponent(accountName);
    return 'otpauth://totp/$encodedIssuer:$encodedAccount?secret=$secretBase32&issuer=$encodedIssuer&algorithm=SHA1&digits=6&period=30';
  }
}
