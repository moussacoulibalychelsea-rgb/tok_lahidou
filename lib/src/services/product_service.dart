import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ProductService {
  final CollectionReference? _col;

  /// If Firebase is not initialized, `_col` will be null and methods return safe fallbacks.
  ProductService() : _col = _tryGetCollection();

  static CollectionReference? _tryGetCollection() {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance.collection('products');
    } catch (_) {
      return null;
    }
  }

  /// Fetch products page by page using a cursor. Returns a map with `products` and `lastDoc`.
  Future<Map<String, dynamic>> fetchProducts({DocumentSnapshot? startAfter, int limit = 12}) async {
    try {
      if (_col == null) return {'products': <Map<String, dynamic>>[], 'lastDoc': null};
      Query q = _col!.orderBy('createdAt', descending: true).limit(limit);
      if (startAfter != null) q = q.startAfterDocument(startAfter);
      final snap = await q.get();
      final products = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        return data;
      }).toList();
      final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      return {'products': products, 'lastDoc': lastDoc};
    } catch (_) {
      return {'products': <Map<String, dynamic>>[], 'lastDoc': null};
    }
  }

  /// Fetch products for a given sellerId
  Future<List<Map<String, dynamic>>> fetchProductsBySeller(String sellerId, {int limit = 50}) async {
    try {
      if (_col == null) return [];
      final snap = await _col!.where('sellerId', isEqualTo: sellerId).orderBy('createdAt', descending: true).limit(limit).get();
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Toggle like for a product by a user. Returns new liked state (true = liked).
  Future<bool> toggleLike(String productId, String userId) async {
    try {
      if (_col == null) return false;
      final likeRef = _col!.doc(productId).collection('likes').doc(userId);
      final likeSnap = await likeRef.get();
      if (likeSnap.exists) {
        // unlike
        await likeRef.delete();
        await _col.doc(productId).update({'likesCount': FieldValue.increment(-1)});
        return false;
      } else {
        await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
        await _col.doc(productId).update({'likesCount': FieldValue.increment(1)});
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Stream a product document for realtime updates.
  Stream<DocumentSnapshot> productStream(String productId) {
    try {
      if (_col == null) return const Stream.empty();
      return _col!.doc(productId).snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Stream the like document for a specific user on a product.
  Stream<DocumentSnapshot> likeStream(String productId, String userId) {
    try {
      if (_col == null) return const Stream.empty();
      return _col!.doc(productId).collection('likes').doc(userId).snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Check which of the given productIds are liked by the user.
  Future<Set<String>> fetchLikedIds(List<String> productIds, String userId) async {
    final liked = <String>{};
    try {
      if (_col == null) return liked;
      // perform parallel reads for each product's like doc
      final futures = productIds.map((pid) => _col!.doc(pid).collection('likes').doc(userId).get());
      final snaps = await Future.wait(futures);
      for (var i = 0; i < productIds.length; i++) {
        final s = snaps[i];
        if (s.exists) liked.add(productIds[i]);
      }
    } catch (_) {
      // ignore errors, return what we have
    }
    return liked;
  }
}
