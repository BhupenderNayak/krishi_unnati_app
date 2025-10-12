import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  bool _isCodeSent = false;

  Timer? _timer;
  int _countdown = 30;


  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {

        if (mounted) {
          setState(() => _countdown--);
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _verifyPhoneNumber() async {
    // This logic remains the same
    setState(() => _isLoading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${_phoneController.text.trim()}',
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: ${e.message}')));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isCodeSent = true;
          });
          _startTimer();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() => _verificationId = verificationId);
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signInWithOTP() async {
    // This logic remains the same
    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign In Failed: ${e.message}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isCodeSent)
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: '10-digit Mobile Number', prefixText: '+91 ', border: OutlineInputBorder()), keyboardType: TextInputType.phone)
            else
              TextFormField(controller: _otpController, decoration: const InputDecoration(labelText: 'Enter 6-digit OTP', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                onPressed: _isCodeSent ? _signInWithOTP : _verifyPhoneNumber,
                child: Text(_isCodeSent ? 'Verify & Sign In' : 'Send OTP'),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50))),
            if (_isCodeSent)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive code? "),
                    _countdown > 0
                        ? Text("Resend in $_countdown s", style: const TextStyle(color: Colors.grey))
                        : TextButton(onPressed: _verifyPhoneNumber, child: const Text("Resend OTP")),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}