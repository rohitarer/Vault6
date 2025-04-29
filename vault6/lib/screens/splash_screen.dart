import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vault6/screens/home_screen.dart';
import 'package:vault6/services/cleanup_service.dart'; // 👈 Import the cleanup function
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      // ✅ Initialize Firebase only
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized');

      // ⛔ No Supabase initialize here

      // ✅ Clean expired files
      await autoCleanupExpiredFiles();

      // ✅ After 3 seconds, navigate to HomeScreen
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    } catch (e) {
      debugPrint('❌ Initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: colorScheme.onPrimary),
            const SizedBox(height: 20),
            Text(
              'Vault6',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Secure file vault for 24hrs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'home_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Navigate to HomeScreen after a short delay
//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     });
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: colorScheme.primary,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.lock_outline, size: 64, color: colorScheme.onPrimary),
//             const SizedBox(height: 20),
//             Text(
//               'Vault6',
//               style: TextStyle(
//                 fontSize: 42,
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.onPrimary,
//                 letterSpacing: 1.5,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Secure file vault for 24hrs',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 color: colorScheme.onPrimary.withOpacity(0.9),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
