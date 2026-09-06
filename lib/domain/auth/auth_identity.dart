class AuthIdentity {
  const AuthIdentity({required this.uid, required this.phoneNumber, this.isDemo = false});

  final String uid;
  final String? phoneNumber;
  final bool isDemo;
}
