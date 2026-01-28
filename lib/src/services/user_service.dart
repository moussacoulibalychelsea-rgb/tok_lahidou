import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class UserService {
  final CollectionReference? _users;

  UserService() : _users = _tryGetCollection();

  static CollectionReference? _tryGetCollection() {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance.collection('users');
    } catch (_) {
      return null;
    }
  }

  /// Toggle follow relationship between current user and seller.
  /// Returns true if now following.
  Future<bool> toggleFollow({required String sellerId, required String userId}) async {
    try {
      if (_users == null) return false;
      final followerRef = _users!.doc(sellerId).collection('followers').doc(userId);
      final followingRef = _users!.doc(userId).collection('following').doc(sellerId);
      final snap = await followerRef.get();
      if (snap.exists) {
        // unfollow
        await followerRef.delete();
        await followingRef.delete();
        await _users!.doc(sellerId).update({'followersCount': FieldValue.increment(-1)});
        return false;
      } else {
        await followerRef.set({'createdAt': FieldValue.serverTimestamp()});
        await followingRef.set({'createdAt': FieldValue.serverTimestamp()});
        await _users!.doc(sellerId).set({'followersCount': FieldValue.increment(1)}, SetOptions(merge: true));
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> isFollowing({required String sellerId, required String userId}) async {
    try {
      if (_users == null) return false;
      final snap = await _users!.doc(sellerId).collection('followers').doc(userId).get();
      return snap.exists;
    } catch (_) {
      return false;
    }
  }
}
