import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

class TOTPEntry {
  final String siteName;
  final String secret;

  TOTPEntry({required this.siteName, required this.secret});

  String generateTOTP({int digits = 6, int period = 30}) {
    List<int> key = base32.decode(secret.toUpperCase().replaceAll(' ', ''));
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int timeStep = timestamp ~/ period;

    List<int> time = [];
    for (int i = 7; i >= 0; i--) {
      time.add(timeStep & 0xff);
      timeStep >>= 8;
    }

    Hmac hmac = Hmac(sha1, key);
    Digest hash = hmac.convert(time);

    int offset = hash.bytes[hash.bytes.length - 1] & 0xf;
    int binary = ((hash.bytes[offset] & 0x7f) << 24) |
    ((hash.bytes[offset + 1] & 0xff) << 16) |
    ((hash.bytes[offset + 2] & 0xff) << 8) |
    (hash.bytes[offset + 3] & 0xff);

    int otp = binary % pow(10, digits).toInt();
    return otp.toString().padLeft(digits, '0');
  }
}