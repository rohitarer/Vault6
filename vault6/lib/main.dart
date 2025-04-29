import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vault6/core/theme.dart';
import 'package:vault6/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase first
    await Firebase.initializeApp();
    debugPrint("✅ Firebase initialized");

    // ✅ Then initialize Supabase
    await Supabase.initialize(
      url: 'https://dhhmjufoylcljdjhglpy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRoaG1qdWZveWxjbGpkamhnbHB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1MTI5OTcsImV4cCI6MjA2MTA4ODk5N30.cLFurZ6cBM8Wf94L1JsiEJ6SLb6IQp6KRneijim0s8M',
    );
    debugPrint("✅ Supabase initialized successfully");

    // ✅ Clear temp files picked previously
    await FilePicker.platform.clearTemporaryFiles();

    runApp(const ProviderScope(child: Vault6App()));
  } catch (e) {
    debugPrint("❌ App init failed: $e");
  }
}

class Vault6App extends StatelessWidget {
  const Vault6App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault6',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
