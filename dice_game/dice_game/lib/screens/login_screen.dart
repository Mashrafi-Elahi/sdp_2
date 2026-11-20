import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme.dart';
import 'register_screen.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFF2D1515) : const Color(0xFF162E1A),
        content: Text(
          message,
          style: TextStyle(color: isError ? const Color(0xFFFF7B72) : GHColors.green),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Incorrect email or password.',
        'invalid-email' => 'Please enter a valid email address.',
        'too-many-requests' => 'Too many failed attempts. Try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => e.message ?? 'Login failed (${e.code}).',
      };
      _showMessage(message);
    } catch (e) {
      _showMessage('Login error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled picker
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showMessage('Google Sign-In failed: ${e.message ?? e.code}');
    } catch (e) {
      _showMessage('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email in the field above first.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset link sent to $email', isError: false);
    } on FirebaseAuthException catch (e) {
      _showMessage('Reset failed: ${e.message ?? e.code}');
    }
  }

  void _playAsGuest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainMenuScreen(isGuest: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GHColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: GHColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GHColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'images/app_icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign in to Dice Game',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: GHColors.textBright,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: GHColors.text),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email / Gmail',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: GHColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: GHColors.text),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: GHColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: GHColors.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(fontSize: 12, color: GHColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sign In button
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: CircularProgressIndicator(color: GHColors.green),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text('Sign In'),
                          ),
                        ),
                  const SizedBox(height: 14),

                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.g_mobiledata,
                          color: Color(0xFF4285F4),
                          size: 22,
                        ),
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: GHColors.textBright,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: GHColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: GHColors.border),
                  const SizedBox(height: 8),

                  // Register link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Don\'t have an account? Register here'),
                  ),
                  const SizedBox(height: 4),

                  // Guest Mode
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _playAsGuest,
                      icon: const Icon(Icons.person_outline,
                          color: GHColors.textMuted),
                      label: const Text(
                        'Play as Guest',
                        style: TextStyle(color: GHColors.text),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: GHColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}