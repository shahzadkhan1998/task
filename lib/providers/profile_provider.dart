import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/profile_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      scheduleMicrotask(notifyListeners);
    }
  }

  void _setUploading(bool uploading) {
    if (_isUploading != uploading) {
      _isUploading = uploading;
      scheduleMicrotask(notifyListeners);
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      scheduleMicrotask(notifyListeners);
    }
  }

  Future<void> loadProfile(String uid) async {
    try {
      _setLoading(true);
      _setError(null);

      _profile = await _firestoreService.getProfile(uid);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfile(ProfileModel profile) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.saveProfile(profile);
      _profile = profile;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String uid, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.updateProfile(uid, updates);

      // Update local profile
      if (_profile != null) {
        _profile = ProfileModel.fromMap({..._profile!.toMap(), ...updates});
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadProfilePicture(String uid, File file) async {
    try {
      _setUploading(true);
      _setError(null);

      String downloadURL = await _storageService.uploadProfilePicture(
        uid,
        file,
      );

      // Update profile with new photo URL
      await updateProfile(uid, {'photoURL': downloadURL});

      return downloadURL;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setUploading(false);
    }
  }

  Future<String?> uploadDocument(String uid, File file, String fileName) async {
    try {
      _setUploading(true);
      _setError(null);

      final downloadURL = await _storageService.uploadDocument(
        uid,
        file,
        fileName,
      );

      final newDocument = DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        url: downloadURL,
        type: fileName.split('.').last,
        size: await file.length(),
        uploadedAt: DateTime.now(),
      );

      await _firestoreService.updateProfile(uid, {
        'documents': FieldValue.arrayUnion([newDocument.toMap()])
      });

      if (_profile != null) {
        final updatedDocuments = List<DocumentModel>.from(_profile!.documents)
          ..add(newDocument);
        _profile = _profile!.copyWith(documents: updatedDocuments);
        notifyListeners();
      }

      return downloadURL;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setUploading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
