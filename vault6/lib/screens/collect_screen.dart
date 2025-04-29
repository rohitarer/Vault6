import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CollectScreen extends StatefulWidget {
  const CollectScreen({super.key});

  @override
  State<CollectScreen> createState() => _CollectScreenState();
}

class _CollectScreenState extends State<CollectScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> files = [];
  bool isLoading = false;
  bool noResults = false;
  bool initialized = false;

  /// ✅ Ensure Firebase is initialized once
  Future<void> ensureFirebaseInitialized() async {
    if (!initialized) {
      await Firebase.initializeApp();
      initialized = true;
      debugPrint("✅ Firebase initialized (Collect Screen)");
    }
  }

  /// 🔍 Fetch files by 6-digit OTP
  // Future<void> fetchFilesByOtp() async {
  //   final enteredOtp = _otpController.text.trim();
  //   if (enteredOtp.length != 6) return;

  //   await ensureFirebaseInitialized();

  //   setState(() {
  //     isLoading = true;
  //     noResults = false;
  //     files.clear();
  //   });

  //   try {
  //     final userDocs = await firestore.collection('vault6_users').get();

  //     for (final user in userDocs.docs) {
  //       final uploadsRef = firestore
  //           .collection('vault6_users')
  //           .doc(user.id)
  //           .collection('uploads');

  //       final otpDoc = await uploadsRef.doc(enteredOtp).get();

  //       if (otpDoc.exists) {
  //         final data = otpDoc.data();
  //         final expiry = data?['expiresAt']?.toDate();
  //         if (expiry != null && expiry.isAfter(DateTime.now())) {
  //           setState(() {
  //             files = [data!]; // Only one file matches OTP
  //             isLoading = false;
  //           });
  //           return;
  //         }
  //       }
  //     }

  //     setState(() {
  //       noResults = true;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     debugPrint("❌ Error fetching files: $e");
  //     setState(() {
  //       noResults = true;
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchFilesByOtp() async {
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.length != 6) return;

    await ensureFirebaseInitialized();

    setState(() {
      isLoading = true;
      noResults = false;
      files.clear();
    });

    try {
      final userDocs = await firestore.collection('vault6_users').get();

      for (final user in userDocs.docs) {
        final uploadsRef = firestore
            .collection('vault6_users')
            .doc(user.id)
            .collection('uploads');

        final otpDoc = await uploadsRef.doc(enteredOtp).get();

        if (otpDoc.exists) {
          final allUploads = await uploadsRef.get();

          final validFiles = <Map<String, dynamic>>[];

          for (final doc in allUploads.docs) {
            final data = doc.data();
            final expiresAt = (data['expiresAt'] as Timestamp).toDate();

            if (expiresAt.isAfter(DateTime.now())) {
              validFiles.add(data);
            } else {
              // 🧹 Auto Delete expired file
              await deleteExpiredFile(user.id, doc.id, data['storagePath']);
            }
          }

          setState(() {
            files = validFiles;
            isLoading = false;
          });
          return;
        }
      }

      setState(() {
        noResults = true;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching files: $e");
      setState(() {
        noResults = true;
        isLoading = false;
      });
    }
  }

  Future<void> deleteExpiredFile(
    String uid,
    String code,
    String storagePath,
  ) async {
    try {
      // ❌ Delete metadata from Firestore
      await FirebaseFirestore.instance
          .collection('vault6_users')
          .doc(uid)
          .collection('uploads')
          .doc(code)
          .delete();

      debugPrint("🗑️ Firestore metadata deleted for $code");

      // ❌ Delete actual file from Supabase
      final deleteResponse = await Supabase.instance.client.storage
          .from('vault6-files')
          .remove([storagePath]);

      debugPrint("🗑️ Supabase file deleted: $storagePath");
    } catch (e) {
      debugPrint("❌ Error deleting expired file: $e");
    }
  }

  /// ⬇️ Launch file download in browser
  Future<void> downloadFile(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Cannot launch URL");
      }
    } catch (e) {
      debugPrint("❌ Could not launch: $url");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Could not open download link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Vault6 – Collect Files")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              /// 🔢 OTP input
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: "Enter 6-digit OTP",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),

              /// 🔘 Fetch Button
              ElevatedButton.icon(
                onPressed: isLoading ? null : fetchFilesByOtp,
                icon: const Icon(Icons.search),
                label:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text("Fetch Files"),
              ),
              const SizedBox(height: 24),

              /// ❌ No result
              if (noResults)
                const Text(
                  "❌ No files found or OTP expired.",
                  style: TextStyle(color: Colors.red),
                ),

              /// 📂 Display files
              if (files.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: files.length,
                  itemBuilder: (_, index) {
                    final file = files[index];
                    final fileName = file['fileName'] ?? 'Unnamed File';
                    final expires = file['expiresAt']?.toDate();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(fileName),
                        subtitle:
                            expires != null
                                ? Text(
                                  'Expires at: $expires',
                                  style: const TextStyle(fontSize: 12),
                                )
                                : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed:
                              () => downloadFile(file['downloadUrl'] ?? ''),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
