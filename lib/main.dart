import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';
import 'app_theme_notifier.dart';
import 'screens/shell.dart';
import 'screens/login_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Seed Firestore collections if empty
  FirestoreService.seedExpertsIfEmpty();
  FirestoreService.seedOutbreaksIfEmpty();
  runApp(const VisionGROApp());
}

class VisionGROApp extends StatelessWidget {
  const VisionGROApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appTheme,
      builder: (_, __) => MaterialApp(
        title: 'VisionGRO',
        debugShowCheckedModeBanner: false,
        themeMode: appTheme.mode,
        theme: buildTheme(),
        darkTheme: buildDarkTheme(),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snap.hasData && snap.data != null) return const AppShell();
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
