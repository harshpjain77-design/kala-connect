import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth/auth_repository.dart';
import '../domain/auth/auth_identity.dart';

enum AuthPhase { loading, signedOut, sendingCode, codeSent, signedIn, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);
  final AuthRepository _repository;
  StreamSubscription<AuthIdentity?>? _subscription;
  AuthPhase _phase = AuthPhase.loading;
  AuthIdentity? _identity;
  String? _verificationId;
  String? _message;

  AuthPhase get phase => _phase;
  AuthIdentity? get identity => _identity;
  String? get message => _message;
  bool get isSignedIn => _identity != null;

  void start() {
    _subscription = _repository.watchIdentity().listen((identity) {
      _identity = identity;
      _phase = identity == null ? AuthPhase.signedOut : AuthPhase.signedIn;
      notifyListeners();
    }, onError: (Object error) {
      _phase = AuthPhase.error;
      _message = error.toString();
      notifyListeners();
    });
  }

  Future<void> requestOtp(String phoneNumber) async {
    _phase = AuthPhase.sendingCode;
    _message = null;
    notifyListeners();
    try {
      await _repository.requestPhoneOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) => _verificationId = verificationId,
      );
      if (_identity == null) _phase = AuthPhase.codeSent;
    } catch (error) {
      _phase = AuthPhase.error;
      _message = error.toString();
    }
    notifyListeners();
  }

  Future<void> confirmOtp(String code) async {
    final verificationId = _verificationId;
    if (verificationId == null) return;
    _phase = AuthPhase.sendingCode;
    notifyListeners();
    try {
      _identity = await _repository.confirmPhoneOtp(verificationId: verificationId, smsCode: code);
      _phase = AuthPhase.signedIn;
    } catch (error) {
      _phase = AuthPhase.error;
      _message = error.toString();
    }
    notifyListeners();
  }

  Future<void> signOut() => _repository.signOut();

  @override
  void dispose() { _subscription?.cancel(); super.dispose(); }
}
