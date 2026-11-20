import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart'; // <-- Import path must match

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DiceGameApp());
}

class DiceGameApp extends StatelessWidget {
  const DiceGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Game',
      debugShowCheckedModeBanner: false,
      theme: githubTheme(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: GHColors.accent),
              ),
            );
          }

          if (snapshot.hasData) {
            return const MainMenuScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}