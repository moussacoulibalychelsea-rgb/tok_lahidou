import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class StorageService {
  /// Upload image file to Firebase Storage if available.
  /// Returns the download URL on success, otherwise returns the local file path as fallback.
  static Future<String> uploadImage(File file, {String? filename}) async {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) throw Exception('Firebase not initialized');
      final name = filename ?? DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('products/$name.jpg');
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      // Fallback: return file path so UI can use local preview
      return file.path;
    }
  }

  /// Add product document to Firestore (best-effort).
  static Future<void> addProductToFirestore(Map<String, dynamic> product) async {
    try {
      if (Firebase.apps.isEmpty) throw Exception('Firebase not initialized');
      await FirebaseFirestore.instance.collection('products').add(product);
    } catch (_) {
      // ignore errors in fallback/mock mode
    }
  }
}
