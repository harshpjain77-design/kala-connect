import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_flow_controller.dart';
import '../../state/auth_controller.dart';
import '../../theme/kala_theme.dart';
import '../../widgets/ambient_living_canvas.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phone = TextEditingController(text: '+91');
  final _code = TextEditingController();
  @override
  void dispose() { _phone.dispose(); _code.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final askingCode = auth.phase == AuthPhase.codeSent || auth.phase == AuthPhase.error && _code.text.isNotEmpty;
    return Scaffold(
      body: AmbientLivingCanvas(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(27),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              IconButton(onPressed: context.read<AppFlowController>().returnToLanding, icon: const Icon(Icons.arrow_back_rounded)),
              const Spacer(),
              const Icon(Icons.lock_person_rounded, color: KalaColors.terracotta, size: 69),
              const SizedBox(height: 22),
              Text(askingCode ? 'Enter your verification code' : 'Enter your mobile number', style: const TextStyle(fontSize: 33, height: 1.1, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(askingCode ? 'We sent a secure OTP to your phone.' : 'We will send an OTP to keep your account secure.', style: const TextStyle(fontSize: 17, height: 1.3)),
              const SizedBox(height: 26),
              TextField(controller: askingCode ? _code : _phone, keyboardType: TextInputType.phone, autofocus: true, maxLength: askingCode ? 6 : 13, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900), decoration: InputDecoration(counterText: '', filled: true, fillColor: Colors.white.withOpacity(.78), border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none))),
              if (auth.message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(auth.message!, style: const TextStyle(color: KalaColors.terracotta, fontWeight: FontWeight.w700))),
              const SizedBox(height: 17),
              FilledButton(
                onPressed: auth.phase == AuthPhase.sendingCode ? null : () => askingCode ? auth.confirmOtp(_code.text.trim()) : auth.requestOtp(_phone.text.trim()),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60), backgroundColor: KalaColors.terracotta, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: Text(auth.phase == AuthPhase.sendingCode ? 'Please wait…' : askingCode ? 'Verify' : 'Send OTP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              const Spacer(flex: 2),
              const Text('Secure mobile verification', style: TextStyle(color: Color(0x885E4C38))),
            ]),
          ),
        ),
      ),
    );
  }
}
