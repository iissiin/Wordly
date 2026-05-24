import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_facade.dart';

/// Конкретная реализация FirebaseFacade.
/// Здесь — единственное место в проекте, где используется Firebase SDK.
/// Всё остальное работает через абстракцию FirebaseFacade.
class FirebaseFacadeImpl implements FirebaseFacade {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final GoogleSignIn _googleSignIn;

  FirebaseFacadeImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
    required FirebaseStorage storage,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _messaging = messaging,
        _googleSignIn = googleSignIn;

  // ─── HELPERS ─────────────────────────────────────────────

  CollectionReference _userDictionaries(String userId) =>
      _firestore.collection('users').doc(userId).collection('dictionaries');

  CollectionReference _dictionaryWords(
    String userId,
    String dictionaryId,
  ) =>
      _userDictionaries(userId).doc(dictionaryId).collection('words');

  // ─── AUTH ────────────────────────────────────────────────

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Удаляем данные из Firestore
    await _deleteUserData(user.uid);

    // Re-authenticate перед удалением (требование Firebase)
    final googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    }

    await user.delete();
    await _googleSignIn.signOut();
  }

  Future<void> _deleteUserData(String userId) async {
    // Удаляем все словари и слова
    final dicts = await _userDictionaries(userId).get();
    final batch = _firestore.batch();

    for (final dict in dicts.docs) {
      final words = await _dictionaryWords(userId, dict.id).get();
      for (final word in words.docs) {
        batch.delete(word.reference);
      }
      batch.delete(dict.reference);
    }

    // Удаляем документ пользователя
    batch.delete(_firestore.collection('users').doc(userId));
    await batch.commit();
  }

  // ─── FIRESTORE — USER ────────────────────────────────────

  @override
  Future<void> setUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  @override
  Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // ─── FIRESTORE — DICTIONARIES ────────────────────────────

  @override
  Stream<List<Map<String, dynamic>>> watchDictionaries(
    String userId,
  ) {
    return _userDictionaries(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  @override
  Future<Map<String, dynamic>?> getDictionary({
    required String userId,
    required String dictionaryId,
  }) async {
    final doc = await _userDictionaries(userId).doc(dictionaryId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
  }

  @override
  Future<String> createDictionary({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final ref = await _userDictionaries(userId).add(data);
    return ref.id;
  }

  @override
  Future<void> updateDictionary({
    required String userId,
    required String dictionaryId,
    required Map<String, dynamic> data,
  }) async {
    await _userDictionaries(userId).doc(dictionaryId).update(data);
  }

  @override
  Future<void> deleteDictionary({
    required String userId,
    required String dictionaryId,
  }) async {
    // Сначала удаляем все слова
    final words = await _dictionaryWords(userId, dictionaryId).get();
    final batch = _firestore.batch();
    for (final word in words.docs) {
      batch.delete(word.reference);
    }
    batch.delete(_userDictionaries(userId).doc(dictionaryId));
    await batch.commit();
  }

  // ─── FIRESTORE — WORDS ───────────────────────────────────

  @override
  Stream<List<Map<String, dynamic>>> watchWords({
    required String userId,
    required String dictionaryId,
  }) {
    return _dictionaryWords(userId, dictionaryId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  @override
  Future<String> createWord({
    required String userId,
    required String dictionaryId,
    required Map<String, dynamic> data,
  }) async {
    final ref = await _dictionaryWords(userId, dictionaryId).add(data);
    return ref.id;
  }

  @override
  Future<void> updateWord({
    required String userId,
    required String dictionaryId,
    required String wordId,
    required Map<String, dynamic> data,
  }) async {
    await _dictionaryWords(userId, dictionaryId).doc(wordId).update(data);
  }

  @override
  Future<void> deleteWord({
    required String userId,
    required String dictionaryId,
    required String wordId,
  }) async {
    await _dictionaryWords(userId, dictionaryId).doc(wordId).delete();
  }

  @override
  Future<void> createWordsBatch({
    required String userId,
    required String dictionaryId,
    required List<Map<String, dynamic>> words,
  }) async {
    final batch = _firestore.batch();
    for (final word in words) {
      final ref = _dictionaryWords(userId, dictionaryId).doc();
      batch.set(ref, word);
    }
    await batch.commit();
  }

  @override
  Future<void> deleteWordsBatch({
    required String userId,
    required String dictionaryId,
    required List<String> wordIds,
  }) async {
    final batch = _firestore.batch();
    for (final id in wordIds) {
      final ref = _dictionaryWords(userId, dictionaryId).doc(id);
      batch.delete(ref);
    }
    await batch.commit();
  }

  // ─── MESSAGING ───────────────────────────────────────────

  @override
  Future<String?> getFCMToken() async {
    return _messaging.getToken();
  }

  @override
  Future<void> requestNotificationPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<void> saveFCMToken({
    required String userId,
    required String token,
  }) async {
    await _firestore.collection('users').doc(userId).set(
      {'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }
}
