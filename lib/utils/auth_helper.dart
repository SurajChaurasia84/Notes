import 'package:local_auth/local_auth.dart';

class AuthHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware and is capable of running biometrics.
  static Future<bool> checkBiometrics() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Triggers biometric authentication (fingerprint only, no passcode/PIN fallback).
  /// Returns [true] if successfully authenticated, [false] otherwise.
  static Future<bool> authenticate() async {
    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to access Note Karo',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return authenticated;
    } catch (_) {
      return false;
    }
  }
}
