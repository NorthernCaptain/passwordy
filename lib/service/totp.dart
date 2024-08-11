import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

class OTPEntry {
  String siteName;
  String secret;
  String siteId;
  int period = 30;
  int counter = 0;
  int digits = 6;
  String algorithm = 'SHA1';
  String type = 'totp';
  String issuer = '';
  late Hash hash;

  OTPEntry({required this.siteName, required this.secret})
      :
        siteId = siteName.toLowerCase().replaceAll(' ', '-'),
        period = 30,
        digits = 6,
        algorithm = 'SHA1',
        hash = sha1,
        issuer = siteName.split(':')[0]
  ;

  OTPEntry.fromUri(Uri uri)
      :siteName = '',
        secret = '',
        siteId = '' {
    if (uri.scheme == 'otpauth') {
      algorithm = uri.queryParameters['algorithm'] ?? 'SHA1';
      hash = _getHash();
      digits = int.parse(uri.queryParameters['digits'] ?? '6');
      siteName = uri.pathSegments.join(' ').replaceAll(':', ': ');
      secret = uri.queryParameters['secret'] ?? '';
      issuer = uri.queryParameters['issuer'] ?? uri.pathSegments[0].split(':')[0];
      siteId = '${siteName.toLowerCase().replaceAll(' ', '-')}-$issuer';
      if (secret.isEmpty) {
        throw Exception('Invalid URI, secret is required');
      }
      // Check if the URI is a TOTP or HOTP
      if (uri.host == 'totp') {
        type = 'totp';
        period = int.parse(uri.queryParameters['period'] ?? '30');
      }
      else if (uri.host == 'hotp') {
        type = 'hotp';
        counter = int.parse(uri.queryParameters['counter']!);
      } else {
        throw Exception('Invalid URI, not a TOTP URI');
      }
      //check if the OTP is correct by generating it
      generateOTP();
    } else {
      throw Exception('Invalid URI, not a TOTP URI');
    }
  }

  String generateOTP() {
    if (type == 'hotp') {
      return generateHOTP();
    } else {
      return generateTOTP();
    }
  }

  String generateTOTP() {
    List<int> key = base32.decode(secret.toUpperCase().replaceAll(' ', ''));
    int timestamp = DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000;
    int timeStep = timestamp ~/ period;

    List<int> time = [];
    for (int i = 7; i >= 0; i--) {
      time.add(timeStep & 0xff);
      timeStep >>= 8;
    }

    Hmac hmac = Hmac(hash, key);
    Digest digest = hmac.convert(time);

    int offset = digest.bytes[digest.bytes.length - 1] & 0xf;
    int binary = ((digest.bytes[offset] & 0x7f) << 24) |
    ((digest.bytes[offset + 1] & 0xff) << 16) |
    ((digest.bytes[offset + 2] & 0xff) << 8) |
    (digest.bytes[offset + 3] & 0xff);

    int otp = binary % pow(10, digits).toInt();
    return otp.toString().padLeft(digits, '0');
  }

  String generateHOTP({int digits = 6}) {
    List<int> key = base32.decode(secret.toUpperCase().replaceAll(' ', ''));

    // Convert counter to byte array
    List<int> counterBytes = [];
    for (int i = 7; i >= 0; i--) {
      counterBytes.add((counter >> (i * 8)) & 0xFF);
    }

    Hmac hmac = Hmac(sha1, key);
    Digest hash = hmac.convert(counterBytes);

    int offset = hash.bytes[hash.bytes.length - 1] & 0xf;
    int binary = ((hash.bytes[offset] & 0x7f) << 24) |
    ((hash.bytes[offset + 1] & 0xff) << 16) |
    ((hash.bytes[offset + 2] & 0xff) << 8) |
    (hash.bytes[offset + 3] & 0xff);

    int otp = binary % pow(10, digits).toInt();
    return otp.toString().padLeft(digits, '0');
  }

  void incrementCounter() {
    counter++;
  }

  int secondsRemaining() {
    int timestamp = DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000;
    return period - (timestamp % period);
  }

  Hash _getHash() {
    switch (algorithm) {
      case 'SHA1':
        return sha1;
      case 'SHA256':
        return sha256;
      case 'SHA512':
        return sha512;
      default:
        throw Exception('Invalid algorithm');
    }
  }

  bool isTotp() {
    return type == 'totp';
  }

  Uri toUri() {
    Map<String, dynamic> params = {
      'secret': secret,
      'issuer': issuer,
      'algorithm': algorithm,
      'digits': digits.toString(),
    };
    if (type == 'totp') {
      params['period'] = period.toString();
    } else {
      params['counter'] = counter.toString();
    }
    List<String> pathSegments = [siteName.replaceAll(' ', '')];
    return Uri(
      scheme: 'otpauth',
      host: type,
      pathSegments: pathSegments,
      queryParameters: params,
    );
  }
}
