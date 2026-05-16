import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'app_theme_notifier.dart';
import 'screens/shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        home: const AppShell(),
      ),
    );
  }
}
