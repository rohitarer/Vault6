import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final List<PlatformFile> selectedFiles = [];
  final List<String> uploadedCodes = [];
  String? uid;
  bool isUploading = false;
  bool firebaseInitialized = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// ✅ Initialize Firebase and UID
  Future<void> initializeFirebaseAndCreateUid() async {
    if (!firebaseInitialized) {
      await Firebase.initializeApp();
      firebaseInitialized = true;
      debugPrint("✅ Firebase initialized");
    }

    if (uid == null) {
      final newUid = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('vault6_users')
          .doc(newUid)
          .set({'createdAt': FieldValue.serverTimestamp()});
      setState(() => uid = newUid);
      debugPrint("🆔 UID created and saved: $uid");
    }
  }

  /// 🧠 Generate 6-digit OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// 📂 Pick Files
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        selectedFiles
          ..clear()
          ..addAll(result.files);
      });
    }
  }

  /// ❌ Remove File
  void removeFile(int index) {
    setState(() => selectedFiles.removeAt(index));
  }

  /// ☁️ Upload + Metadata Save
  // Future<void> uploadFiles() async {
  //   await initializeFirebaseAndCreateUid();
  //   if (uid == null) return;

  //   setState(() => isUploading = true);

  //   for (final file in selectedFiles) {
  //     try {
  //       final fileName = file.name;
  //       final timestamp = DateTime.now().millisecondsSinceEpoch;
  //       final storagePath = 'vault6/$uid/${timestamp}_$fileName';

  //       debugPrint("⬆️ Uploading $fileName → $storagePath");
  //       await supabase.storage
  //           .from('vault6-files')
  //           .uploadBinary(storagePath, file.bytes!);

  //       final code = generateOtp();
  //       final expiresAt = Timestamp.fromDate(
  //         DateTime.now().add(const Duration(hours: 24)),
  //       );

  //       // final publicUrl =
  //       //     supabase.storage.from('vault6-files').getPublicUrl(storagePath) +
  //       //     '?download=true';

  //       final originalName = file.name;
  //       final extension = originalName.split('.').last;
  //       final baseName = originalName.replaceAll('.$extension', '');

  //       final modifiedFileName = '${baseName}_vault6.$extension';
  //       final publicUrl = supabase.storage
  //           .from('vault6-files')
  //           .getPublicUrl(storagePath);

  //       // ✅ Append download behavior and custom filename
  //       // final downloadUrl =
  //       //     '$publicUrl?download=true&filename=$modifiedFileName';
  //       final downloadUrl =
  //           publicUrl + '?download=true&filename=$modifiedFileName';

  //       final metadataRef = FirebaseFirestore.instance
  //           .collection('vault6_users')
  //           .doc(uid)
  //           .collection('uploads')
  //           .doc(code);

  //       await metadataRef.set({
  //         'fileName': fileName,
  //         'storagePath': storagePath,
  //         // 'downloadUrl': publicUrl,
  //         'downloadUrl': downloadUrl,
  //         'code': code,
  //         'expiresAt': expiresAt,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });

  //       debugPrint("✅ Metadata saved → OTP: $code");
  //       setState(() => uploadedCodes.add(code));
  //     } catch (e) {
  //       debugPrint("❌ Error uploading ${file.name}: $e");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("❌ ${file.name} failed: $e"),
  //           backgroundColor: Colors.red.shade700,
  //         ),
  //       );
  //     }
  //   }

  //   setState(() {
  //     isUploading = false;
  //     selectedFiles.clear();
  //   });
  // }

  Future<void> uploadFiles() async {
    await initializeFirebaseAndCreateUid();
    if (uid == null) return;

    setState(() => isUploading = true);

    for (final file in selectedFiles) {
      try {
        final fileName = file.name;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'vault6/$uid/${timestamp}_$fileName';

        debugPrint("⬆️ Uploading $fileName → $storagePath");

        final uploadResponse = await supabase.storage
            .from('vault6-files')
            .uploadBinary(storagePath, file.bytes!);

        if (uploadResponse.isEmpty) {
          throw Exception('❌ Upload failed');
        }

        final code = generateOtp();
        final expiresAt = Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        );

        // 🔥 Create public URL
        final publicUrl = supabase.storage
            .from('vault6-files')
            .getPublicUrl(storagePath);

        // 🔥 Append ?download=vault6
        final downloadUrl = '$publicUrl?download=vault6';

        // 🔥 Save in Firestore
        final metadataRef = FirebaseFirestore.instance
            .collection('vault6_users')
            .doc(uid)
            .collection('uploads')
            .doc(code);

        await metadataRef.set({
          'fileName': fileName,
          'storagePath': storagePath,
          'downloadUrl': downloadUrl,
          'code': code,
          'expiresAt': expiresAt,
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint("✅ Metadata saved → OTP: $code");
        setState(() => uploadedCodes.add(code));
      } catch (e) {
        debugPrint("❌ Error uploading ${file.name}: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ ${file.name} failed: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }

    setState(() {
      isUploading = false;
      selectedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text('Vault6 – Upload Files')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Upload your files securely 👇",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),

              // 🔘 Upload Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : pickFiles,
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Choose Files"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed:
                        selectedFiles.isNotEmpty && !isUploading
                            ? uploadFiles
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child:
                        isUploading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text("Upload"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 📁 File Preview Chips
              if (selectedFiles.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children:
                      selectedFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(file.name),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => removeFile(index),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

              const SizedBox(height: 40),

              // 🔐 OTP Section
              if (uploadedCodes.isNotEmpty)
                Column(
                  children: [
                    const Text(
                      "🔐 Your Access OTPs (valid for 24 hours)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children:
                          uploadedCodes.map((code) {
                            return Chip(
                              label: Text(
                                code,
                                style: const TextStyle(fontSize: 16),
                              ),
                              backgroundColor: Colors.green.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
