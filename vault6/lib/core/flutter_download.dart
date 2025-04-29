import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadToFile(String url, String filename) async {
  final dir = await getExternalStorageDirectory();
  final savePath = "${dir!.path}/$filename";

  await Dio().download(url, savePath);
  debugPrint("✅ File downloaded to: $savePath");
}
