import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

Future<void> autoCleanupExpiredFiles() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final supabase = Supabase.instance.client;

    final usersSnapshot = await firestore.collection('vault6_users').get();

    for (final userDoc in usersSnapshot.docs) {
      final uid = userDoc.id;

      final uploadsSnapshot =
          await firestore
              .collection('vault6_users')
              .doc(uid)
              .collection('uploads')
              .get();

      for (final uploadDoc in uploadsSnapshot.docs) {
        final data = uploadDoc.data();
        final expiresAt = (data['expiresAt'] as Timestamp).toDate();

        if (expiresAt.isBefore(DateTime.now())) {
          final storagePath = data['storagePath'];

          // ❌ Delete from Firestore
          await firestore
              .collection('vault6_users')
              .doc(uid)
              .collection('uploads')
              .doc(uploadDoc.id)
              .delete();

          debugPrint("🗑️ Deleted metadata for expired OTP: ${uploadDoc.id}");

          // ❌ Delete file from Supabase
          await supabase.storage.from('vault6-files').remove([storagePath]);

          debugPrint("🗑️ Deleted file from Supabase: $storagePath");
        }
      }
    }

    debugPrint("✅ Auto-cleanup finished");
  } catch (e) {
    debugPrint("❌ Error during auto-cleanup: $e");
  }
}
