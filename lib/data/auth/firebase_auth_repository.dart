import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/auth/auth_identity.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  @override
  Stream<AuthIdentity?> watchIdentity() => _auth.authStateChanges().map(_identityFromUser);

  @override
  Future<void> requestPhoneOtp({required String phoneNumber, required void Function(String verificationId) onCodeSent}) async {
    final completion = Completer<void>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        if (!completion.isCompleted) completion.complete();
      },
      verificationFailed: (error) {
        if (!completion.isCompleted) completion.completeError(error);
      },
      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
        if (!completion.isCompleted) completion.complete();
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    await completion.future;
  }

  @override
  Future<AuthIdentity> confirmPhoneOtp({required String verificationId, required String smsCode}) async {
    final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final user = (await _auth.signInWithCredential(credential)).user;
    if (user == null) throw StateError('Firebase did not return an authenticated user.');
    return _identityFromUser(user)!;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthIdentity? _identityFromUser(User? user) => user == null ? null : AuthIdentity(uid: user.uid, phoneNumber: user.phoneNumber);
}
