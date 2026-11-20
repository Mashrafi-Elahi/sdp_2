import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2D1515),
        content: Text(message, style: const TextStyle(color: Color(0xFFFF7B72))),
      ),
    );
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'An account already exists with that email.',
        'invalid-email' => 'Invalid email address format.',
        'weak-password' => 'Password is too weak (min 6 characters).',
        'network-request-failed' => 'Network error. Check connection.',
        _ => e.message ?? 'Registration failed (${e.code}).',
      };
      _showMessage(message);
    } catch (e) {
      _showMessage('Registration error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GHColors.bg,
      appBar: AppBar(
        title: const Text('Create Account'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: GHColors.border, height: 1),
        ),
      ),
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
                    'Create your account',
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
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 14),

                  // Confirm Password
                  TextField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(color: GHColors.text),
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _register(),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: GHColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: GHColors.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  _isLoading
                      ? const CircularProgressIndicator(color: GHColors.green)
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _register,
                            child: const Text('Create Account'),
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