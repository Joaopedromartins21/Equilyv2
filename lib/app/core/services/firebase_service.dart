import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static FirebaseFirestore get firestore => _firestore;

  static String? _userId;

  static void setUserId(String? userId) {
    _userId = userId;
  }

  static String get userPath => _userId != null ? 'users/$_userId' : '';

  static CollectionReference _getUserCollection(String collection) {
    if (_userId == null) {
      return _firestore.collection(collection);
    }
    return _firestore.collection('users').doc(_userId).collection(collection);
  }

  static CollectionReference get transactions =>
      _getUserCollection('transactions');
  static CollectionReference get accounts => _getUserCollection('accounts');
  static CollectionReference get goals => _getUserCollection('goals');
  static CollectionReference get budgets => _getUserCollection('budgets');
  static CollectionReference get recurring => _getUserCollection('recurring');
  static CollectionReference get reminders => _getUserCollection('reminders');
  static CollectionReference get debts => _getUserCollection('debts');

  static Future<void> addDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _getUserCollection(collection).doc(id).set(data);
  }

  static Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _getUserCollection(collection).doc(id).update(data);
  }

  static Future<void> deleteDocument(String collection, String id) async {
    await _getUserCollection(collection).doc(id).delete();
  }

  static Future<DocumentSnapshot?> getDocument(
    String collection,
    String id,
  ) async {
    final doc = await _getUserCollection(collection).doc(id).get();
    return doc.exists ? doc : null;
  }

  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _getUserCollection(collection).snapshots();
  }

  static Future<List<QueryDocumentSnapshot>> getAllDocuments(
    String collection,
  ) async {
    final snapshot = await _getUserCollection(collection).get();
    return snapshot.docs;
  }

  static Future<void> clearUserData() async {
    if (_userId == null) return;

    final collections = [
      'transactions',
      'accounts',
      'goals',
      'budgets',
      'recurring',
      'reminders',
      'debts',
    ];

    for (var collection in collections) {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collection)
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static Future<void> clearAllData() async {
    final collections = [
      'transactions',
      'accounts',
      'goals',
      'budgets',
      'recurring',
      'reminders',
      'debts',
    ];

    for (var collection in collections) {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(collection).get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
