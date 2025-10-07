import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'phone_auth_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmail() async {
    // This logic is standard and should work fine.
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(), password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') message = 'No user found for that email.';
      else if (e.code == 'wrong-password') message = 'Wrong password provided.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: "Enter your email"),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Send Link"),
              onPressed: () async {
                if (emailController.text.trim().isNotEmpty) {
                  try {
                    await _auth.sendPasswordResetEmail(email: emailController.text.trim());
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password reset link sent to your email.")),
                    );
                  } on FirebaseAuthException catch (e) {
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? "An error occurred.")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
  // --- THIS IS THE CORRECT GOOGLE SIGN-IN LOGIC FOR THE PACKAGES SPECIFIED ABOVE ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create an instance of the Google provider
      await GoogleSignIn().signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // 2. Start the interactive sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // 3. If the user cancelled the process, stop
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 4. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 5. Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 6. Sign in to Firebase with the credential
      await _auth.signInWithCredential(credential);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In Failed. Please ensure you have an internet connection and have configured your app correctly in Firebase.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The UI part remains the same
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Kisan Samriddhi', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green[800])),
              const SizedBox(height: 16),
              const Text('Welcome! Sign in to continue.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)), obscureText: true),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text("Forgot Password?"),
                  ),
                ),
              ),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ElevatedButton(onPressed: _signInWithEmail, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Login with Email', style: TextStyle(fontSize: 18))),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())), child: const Text("Don't have an account? Sign Up")),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('OR', style: TextStyle(color: Colors.grey))), Expanded(child: Divider())])),
                  ElevatedButton.icon(icon: Image.asset('assets/images.png', height: 22.0), label: const Text('Sign in with Google'), onPressed: _signInWithGoogle, style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: Colors.grey)))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(icon: const Icon(Icons.phone, color: Colors.white), label: const Text('Sign in with Phone'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneAuthScreen())), style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)))),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

