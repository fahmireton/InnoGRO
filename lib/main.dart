import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'app_theme_notifier.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VisionGROApp());
}

class VisionGROApp extends StatelessWidget {
  const VisionGROApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appTheme,
      builder: (_, __) => MaterialApp(
        title: 'InnoGRO',
        debugShowCheckedModeBanner: false,
        themeMode: appTheme.mode,
        theme: buildTheme(),
        darkTheme: buildDarkTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
