import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../domain/entities/pack_entity.dart';
import '../domain/entities/review_entity.dart';
import '../domain/entities/user_entity.dart';
import '../domain/entities/word_entity.dart';
import '../domain/usecases/review/submit_review_usecase.dart';

class FirebaseFacade {
  // ── Приватные поля — скрытые подсистемы ──────────────────
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FirebaseStorage _storage;
  final GoogleSignIn _googleSignIn;
  final Uuid _uuid;

  // ── Конструктор принимает зависимости (DI) ───────────────
  FirebaseFacade({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FirebaseStorage? storage,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _uuid = const Uuid();

  // ════════════════════════════════════════════════════════
  //  БЛОК 1: АВТОРИЗАЦИЯ
  // ════════════════════════════════════════════════════════

  /// Текущий пользователь (null если не авторизован)
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUserToEntity(user);
  }

  /// Поток изменений авторизации
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      // Загружаем дополнительные данные из Firestore
      return await _getUserFromFirestore(user.uid);
    });
  }

  /// Войти через Google — главный метод авторизации
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Шаг 1: Google Sign-In диалог
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In отменён пользователем');
      }

      // Шаг 2: получаем токены Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Шаг 3: создаём credential для Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Шаг 4: входим в Firebase Auth
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user!;

      // Шаг 5: сохраняем/обновляем профиль в Firestore
      await _saveUserToFirestore(user);

      // Шаг 6: настраиваем push-уведомления
      await _initializeMessaging(user.uid);

      return await _getUserFromFirestore(user.uid);
    } catch (e) {
      throw Exception('Ошибка входа через Google: $e');
    }
  }

  /// Выйти из аккаунта
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ════════════════════════════════════════════════════════
  //  БЛОК 2: ПАКИ СЛОВ
  // ════════════════════════════════════════════════════════

  /// Получить паки пользователя (real-time поток)
  Stream<List<PackEntity>> watchPacks(String userId) {
    return _firestore
        .collection(AppConstants.packsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapDocToPackEntity(doc)).toList());
  }

  /// Создать новый пак
  Future<PackEntity> createPack({
    required String userId,
    required String title,
    String? description,
    String? emoji,
    int colorIndex = 0,
  }) async {
    final String packId = _uuid.v4();
    final now = DateTime.now();

    final data = {
      'id': packId,
      'userId': userId,
      'title': title,
      'description': description,
      'emoji': emoji ?? '📚',
      'colorIndex': colorIndex,
      'totalWords': 0,
      'learnedWords': 0,
      'dueWords': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    await _firestore
        .collection(AppConstants.packsCollection)
        .doc(packId)
        .set(data);

    return PackEntity(
      id: packId,
      userId: userId,
      title: title,
      description: description,
      emoji: emoji ?? '📚',
      colorIndex: colorIndex,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Обновить пак
  Future<void> updatePack(PackEntity pack) async {
    await _firestore
        .collection(AppConstants.packsCollection)
        .doc(pack.id)
        .update({
      'title': pack.title,
      'description': pack.description,
      'emoji': pack.emoji,
      'colorIndex': pack.colorIndex,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Удалить пак и все слова в нём
  Future<void> deletePack(String packId) async {
    // Сначала удаляем все слова пака
    final wordsSnapshot = await _firestore
        .collection(AppConstants.wordsCollection)
        .where('packId', isEqualTo: packId)
        .get();

    // Используем batch для атомарного удаления
    final batch = _firestore.batch();
    for (final doc in wordsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    // Удаляем сам пак
    batch.delete(
        _firestore.collection(AppConstants.packsCollection).doc(packId));

    await batch.commit();
  }

  // ════════════════════════════════════════════════════════
  //  БЛОК 3: СЛОВА
  // ════════════════════════════════════════════════════════

  /// Слова пака (real-time поток)
  Stream<List<WordEntity>> watchWords(String packId) {
    return _firestore
        .collection(AppConstants.wordsCollection)
        .where('packId', isEqualTo: packId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapDocToWordEntity(doc)).toList());
  }

  /// Слова для повторения прямо сейчас
  Future<List<WordEntity>> getDueWords(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());

    final snapshot = await _firestore
        .collection(AppConstants.wordsCollection)
        .where('userId', isEqualTo: userId)
        .where('nextReviewAt', isLessThanOrEqualTo: now)
        .where('reviewStage', isLessThan: AppConstants.maxReviewStage)
        .get();

    return snapshot.docs.map((doc) => _mapDocToWordEntity(doc)).toList();
  }

  /// Добавить слово в пак
  Future<WordEntity> addWord({
    required String packId,
    required String userId,
    required String word,
    required String translation,
    String? example,
    String? transcription,
  }) async {
    final String wordId = _uuid.v4();
    final now = DateTime.now();

    final data = {
      'id': wordId,
      'packId': packId,
      'userId': userId,
      'word': word,
      'translation': translation,
      'example': example,
      'transcription': transcription,
      'reviewStage': 0,
      'nextReviewAt': Timestamp.fromDate(now), // сразу доступно для повторения
      'lastReviewAt': null,
      'status': 'newWord',
      'createdAt': Timestamp.fromDate(now),
    };

    // Транзакция: добавляем слово + обновляем счётчик в паке
    await _firestore.runTransaction((transaction) async {
      final wordRef =
          _firestore.collection(AppConstants.wordsCollection).doc(wordId);
      final packRef =
          _firestore.collection(AppConstants.packsCollection).doc(packId);

      transaction.set(wordRef, data);
      transaction.update(packRef, {
        'totalWords': FieldValue.increment(1),
        'dueWords': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(now),
      });
    });

    return WordEntity(
      id: wordId,
      packId: packId,
      userId: userId,
      word: word,
      translation: translation,
      example: example,
      transcription: transcription,
      nextReviewAt: now,
      createdAt: now,
    );
  }

  /// Удалить слово
  Future<void> deleteWord(String wordId, String packId) async {
    await _firestore.runTransaction((transaction) async {
      final wordRef =
          _firestore.collection(AppConstants.wordsCollection).doc(wordId);
      final packRef =
          _firestore.collection(AppConstants.packsCollection).doc(packId);

      transaction.delete(wordRef);
      transaction.update(packRef, {
        'totalWords': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // ════════════════════════════════════════════════════════
  //  БЛОК 4: ПОВТОРЕНИЕ (алгоритм интервального повторения)
  // ════════════════════════════════════════════════════════

  /// Сохранить результат повторения
  /// Здесь применяется алгоритм интервального повторения
  Future<WordEntity> submitReview({
    required WordEntity word,
    required ReviewResult result,
  }) async {
    // Вычисляем новую стадию и следующее время повторения
    final int nextStage = SubmitReviewUseCase.calculateNextStage(
      currentStage: word.reviewStage,
      result: result,
    );
    final DateTime? nextReviewAt = SubmitReviewUseCase.calculateNextReview(
      currentStage: word.reviewStage,
      result: result,
    );

    final now = DateTime.now();
    final bool isLearned = nextStage >= AppConstants.maxReviewStage;
    final String newStatus = isLearned
        ? 'learned'
        : nextStage > 0
            ? 'learning'
            : 'newWord';

    // Обновляем слово и статистику пака транзакцией
    await _firestore.runTransaction((transaction) async {
      final wordRef =
          _firestore.collection(AppConstants.wordsCollection).doc(word.id);
      final packRef =
          _firestore.collection(AppConstants.packsCollection).doc(word.packId);

      // Обновляем слово
      transaction.update(wordRef, {
        'reviewStage': nextStage,
        'nextReviewAt':
            nextReviewAt != null ? Timestamp.fromDate(nextReviewAt) : null,
        'lastReviewAt': Timestamp.fromDate(now),
        'status': newStatus,
      });

      // Если слово только что выучено — обновляем счётчик пака
      if (isLearned && word.status != WordStatus.learned) {
        transaction.update(packRef, {
          'learnedWords': FieldValue.increment(1),
          'dueWords': FieldValue.increment(-1),
        });
      }

      // Сохраняем запись о повторении
      final reviewId = _uuid.v4();
      final reviewRef = _firestore.collection('reviews').doc(reviewId);
      transaction.set(reviewRef, {
        'id': reviewId,
        'wordId': word.id,
        'userId': word.userId,
        'result': result == ReviewResult.correct ? 'correct' : 'incorrect',
        'stageAfterReview': nextStage,
        'reviewedAt': Timestamp.fromDate(now),
      });
    });

    // Возвращаем обновлённое слово
    return WordEntity(
      id: word.id,
      packId: word.packId,
      userId: word.userId,
      word: word.word,
      translation: word.translation,
      example: word.example,
      transcription: word.transcription,
      reviewStage: nextStage,
      nextReviewAt: nextReviewAt,
      lastReviewAt: now,
      status: isLearned
          ? WordStatus.learned
          : nextStage > 0
              ? WordStatus.learning
              : WordStatus.newWord,
      createdAt: word.createdAt,
    );
  }

  // ════════════════════════════════════════════════════════
  //  БЛОК 5: УВЕДОМЛЕНИЯ
  // ════════════════════════════════════════════════════════

  /// Инициализировать push-уведомления
  Future<void> _initializeMessaging(String userId) async {
    // Запрашиваем разрешение
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Сохраняем FCM токен в Firestore для отправки уведомлений
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  // ════════════════════════════════════════════════════════
  //  БЛОК 6: ХРАНИЛИЩЕ (аватары)
  // ════════════════════════════════════════════════════════

  /// Загрузить фото профиля
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('avatars/$userId/profile.jpg');
    final uploadTask = await ref.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Обновляем URL в Firestore
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'photoUrl': downloadUrl});

    return downloadUrl;
  }

  // ════════════════════════════════════════════════════════
  //  ПРИВАТНЫЕ ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ════════════════════════════════════════════════════════

  /// Сохранить пользователя в Firestore (при первом входе или обновлении)
  Future<void> _saveUserToFirestore(User user) async {
    final docRef =
        _firestore.collection(AppConstants.usersCollection).doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      // Первый вход — создаём профиль
      await docRef.set({
        'id': user.uid,
        'name': user.displayName ?? 'Пользователь',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'totalWordsLearned': 0,
        'currentStreak': 0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  /// Загрузить пользователя из Firestore
  Future<UserEntity> _getUserFromFirestore(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (!doc.exists) {
      throw Exception('Пользователь не найден');
    }

    final data = doc.data()!;
    return UserEntity(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      photoUrl: data['photoUrl'] as String?,
      totalWordsLearned: data['totalWordsLearned'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Firebase User → UserEntity
  UserEntity _mapFirebaseUserToEntity(User user) {
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? 'Пользователь',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Firestore doc → PackEntity
  PackEntity _mapDocToPackEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PackEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      emoji: data['emoji'] as String?,
      colorIndex: data['colorIndex'] as int? ?? 0,
      totalWords: data['totalWords'] as int? ?? 0,
      learnedWords: data['learnedWords'] as int? ?? 0,
      dueWords: data['dueWords'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore doc → WordEntity
  WordEntity _mapDocToWordEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WordEntity(
      id: data['id'] as String,
      packId: data['packId'] as String,
      userId: data['userId'] as String,
      word: data['word'] as String,
      translation: data['translation'] as String,
      example: data['example'] as String?,
      transcription: data['transcription'] as String?,
      reviewStage: data['reviewStage'] as int? ?? 0,
      nextReviewAt: data['nextReviewAt'] != null
          ? (data['nextReviewAt'] as Timestamp).toDate()
          : null,
      lastReviewAt: data['lastReviewAt'] != null
          ? (data['lastReviewAt'] as Timestamp).toDate()
          : null,
      status: _parseWordStatus(data['status'] as String? ?? 'newWord'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  WordStatus _parseWordStatus(String status) {
    switch (status) {
      case 'learning':
        return WordStatus.learning;
      case 'learned':
        return WordStatus.learned;
      default:
        return WordStatus.newWord;
    }
  }
}
