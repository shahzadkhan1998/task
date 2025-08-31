import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _profilesCollection = 'profiles';

  // Create or update profile
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _db
          .collection(_profilesCollection)
          .doc(profile.uid)
          .set(
            profile.copyWith(updatedAt: DateTime.now()).toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to save profile: ${e.toString()}');
    }
  }

  // Get profile by uid
  Future<ProfileModel?> getProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(_profilesCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  // Update profile
  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now();
      await _db.collection(_profilesCollection).doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Delete profile
  Future<void> deleteProfile(String uid) async {
    try {
      await _db.collection(_profilesCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete profile: ${e.toString()}');
    }
  }

  // Stream profile changes
  Stream<ProfileModel?> profileStream(String uid) {
    return _db.collection(_profilesCollection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
