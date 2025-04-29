import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 Generate and store a new UID document under `vault6_users/`
  Future<String> createAnonymousUid() async {
    final uid = const Uuid().v4();

    try {
      await _firestore.collection('vault6_users').doc(uid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active', // Optional tracking
      });

      print("🆔 UID created and saved: $uid");
      return uid;
    } catch (e) {
      print("❌ Firebase UID creation failed: $e");
      rethrow;
    }
  }

  /// ✅ Check if a given UID already exists in Firestore
  Future<bool> uidExists(String uid) async {
    try {
      final doc = await _firestore.collection('vault6_users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print("❌ Error checking UID existence: $e");
      return false;
    }
  }

  /// 💾 Save file metadata under `uploads/{code}` with 24hr expiry
  Future<String> saveFileMetadata({
    required String uid,
    required String fileName,
    required String storagePath,
    required String downloadUrl,
  }) async {
    final code = _generate6DigitCode();
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    final metadata = {
      'uid': uid,
      'code': code,
      'fileName': fileName,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'expiresAt': Timestamp.fromDate(expiresAt),
    };

    try {
      await _firestore.collection('uploads').doc(code).set(metadata);
      print("✅ Metadata saved for code: $code");
      return code;
    } catch (e) {
      print("❌ Metadata save failed: $e");
      rethrow;
    }
  }

  /// 🔢 Internal: Generate a 6-digit OTP code
  String _generate6DigitCode() {
    final random = Uuid().v4().hashCode;
    return (100000 + (random.abs() % 900000)).toString();
  }
}
