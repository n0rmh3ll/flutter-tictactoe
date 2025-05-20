import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext ctx) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;  // user aborted
    final googleAuth = await googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await FirebaseAuth.instance.signInWithCredential(cred);
    Navigator.pushReplacement(
      ctx,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: appGradient),
        child: Center(
          child: ElevatedButton(
            onPressed: () => _signInWithGoogle(context),
            child: const Text('Login with Google'),
          ),
        ),
      ),
    );
  }
}
