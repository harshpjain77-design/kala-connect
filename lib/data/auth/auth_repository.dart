import '../../domain/auth/auth_identity.dart';

abstract class AuthRepository {
  Stream<AuthIdentity?> watchIdentity();
  Future<void> requestPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  });
  Future<AuthIdentity> confirmPhoneOtp({required String verificationId, required String smsCode});
  Future<void> signOut();
}
