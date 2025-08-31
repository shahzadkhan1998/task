import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile picture
  Future<String> uploadProfilePicture(String uid, File file) async {
    try {
      String fileName =
          'profile_pictures/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  // Upload document
  Future<String> uploadDocument(String uid, File file, String fileName) async {
    try {
      String filePath =
          'documents/$uid/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = _storage.ref().child(filePath);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload document: ${e.toString()}');
    }
  }

  // Delete file by URL
  Future<void> deleteFile(String downloadURL) async {
    try {
      Reference ref = _storage.refFromURL(downloadURL);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }
}
