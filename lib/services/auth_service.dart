import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  final _localAuth = LocalAuthentication();

  static const _masterPasswordKey = 'secretpass_master_password_hash';
  static const _biometricEnabledKey = 'secretpass_biometric_enabled';
  static const _ownerNameKey = 'secretpass_owner_name';

  // ─── Master Password ───────────────────────────────────────────

  Future<bool> hasMasterPassword() async {
    final hash = await _storage.read(key: _masterPasswordKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setMasterPassword(String password) async {
    final hash = _hashPassword(password);
    await _storage.write(key: _masterPasswordKey, value: hash);
  }

  Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _storage.read(key: _masterPasswordKey);
    if (storedHash == null) return false;
    return _hashPassword(password) == storedHash;
  }

  Future<bool> changeMasterPassword(String oldPassword, String newPassword) async {
    final valid = await verifyMasterPassword(oldPassword);
    if (!valid) return false;
    await setMasterPassword(newPassword);
    return true;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'secretpass_salt_2024');
    return sha256.convert(bytes).toString();
  }

  // ─── Owner Name ────────────────────────────────────────────────

  Future<void> setOwnerName(String name) async {
    await _storage.write(key: _ownerNameKey, value: name);
  }

  Future<String?> getOwnerName() async {
    return await _storage.read(key: _ownerNameKey);
  }

  // ─── Biometrics ────────────────────────────────────────────────

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<BiometricResult> authenticateWithBiometrics() async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return BiometricResult.notAvailable;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'تحقق من هويتك للوصول إلى SecretPass',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } catch (e) {
      return BiometricResult.error;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricEnabledKey);
    return val == 'true';
  }
}

enum BiometricResult { success, failed, notAvailable, error }
