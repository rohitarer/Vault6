import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vault6/services/firestore_service.dart';

/// 🧠 Singleton Firestore service instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// 📦 UID Provider – Generates a UID only once per session
final uploadUidProvider = FutureProvider<String>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);

  try {
    final uid = await firestoreService.createAnonymousUid();
    return uid;
  } catch (e) {
    throw Exception("❌ UID generation failed: $e");
  }
});

/// 💾 Save metadata provider (callable as future)
final saveMetadataProvider = FutureProvider.family<String, Map<String, String>>(
  (ref, metadata) async {
    final firestoreService = ref.read(firestoreServiceProvider);

    try {
      final code = await firestoreService.saveFileMetadata(
        uid: metadata['uid'] ?? '',
        fileName: metadata['fileName'] ?? '',
        storagePath: metadata['storagePath'] ?? '',
        downloadUrl: metadata['downloadUrl'] ?? '',
      );
      return code;
    } catch (e) {
      throw Exception("❌ Metadata save failed: $e");
    }
  },
);
