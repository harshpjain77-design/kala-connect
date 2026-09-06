import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/auth/auth_identity.dart';
import 'auth_repository.dart';

/// Keeps the visual prototype runnable before Firebase configuration exists.
class DemoAuthRepository implements AuthRepository {
  static const _sessionKey = 'demo_auth_session';
  final StreamController<AuthIdentity?> _controller = StreamController<AuthIdentity?>.broadcast();
  AuthIdentity? _current;

  @override
  Stream<AuthIdentity?> watchIdentity() async* {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_sessionKey) ?? false) {
      _current = const AuthIdentity(
        uid: 'demo-artisan',
        phoneNumber: '+910000000000',
        isDemo: true,
      );
    }
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> requestPhoneOtp({required String phoneNumber, required void Function(String verificationId) onCodeSent}) async {
    onCodeSent('demo-verification');
  }

  @override
  Future<AuthIdentity> confirmPhoneOtp({required String verificationId, required String smsCode}) async {
    if (smsCode != '123456') throw StateError('Use 123456 while Firebase is not configured.');
    _current = const AuthIdentity(uid: 'demo-artisan', phoneNumber: '+910000000000', isDemo: true);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_sessionKey, true);
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
    _controller.add(null);
  }
}
