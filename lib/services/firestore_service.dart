import 'package:bq_quiz_lab/services/push_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================================================
  // STUDENT PROFILE
  // =========================================================

  Future<void> saveStudent({
    required String uid,
    required String name,
    required String email,
    required String classBatch,
    required String campus,
  }) async {
    await _firestore.collection('student').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'student',
      'classBatch': classBatch.trim(),
      'campus': campus.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // TEACHER PROFILE
  // =========================================================

  Future<void> saveTeacher({
    required String uid,
    required String name,
    required String email,
    required String departmentCourse,
    required String campus,
  }) async {
    await _firestore.collection('teacher').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'teacher',
      'departmentCourse': departmentCourse.trim(),
      'campus': campus.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // CONTROLLER PROFILE
  // =========================================================

  Future<void> saveController({
    required String uid,
    required String name,
    required String email,
    required String designation,
    required String campus,
  }) async {
    await _firestore.collection('controller').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'controller',
      'designation': designation.trim(),
      'campus': campus.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // GET USER ROLE
  // =========================================================

  Future<String?> getUserRole(String uid) async {
    final student =
    await _firestore.collection('student').doc(uid).get();

    if (student.exists) {
      return 'student';
    }

    final teacher =
    await _firestore.collection('teacher').doc(uid).get();

    if (teacher.exists) {
      return 'teacher';
    }

    final controller =
    await _firestore.collection('controller').doc(uid).get();

    if (controller.exists) {
      return 'controller';
    }

    return null;
  }

  // =========================================================
  // TEACHER PROFILE STREAM
  // =========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> teacherProfileStream(
      String teacherId,
      ) {
    return _firestore
        .collection('teacher')
        .doc(teacherId)
        .snapshots();
  }

  // =========================================================
  // QUESTIONS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> teacherQuestionsStream(
      String teacherId,
      ) {
    return _firestore
        .collection('questions')
        .where(
      'teacherId',
      isEqualTo: teacherId,
    )
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getQuestion(
      String questionId,
      ) async {
    return _firestore
        .collection('questions')
        .doc(questionId)
        .get();
  }

  Future<String> createQuestion({
    required String teacherId,
    required String subject,
    required String difficulty,
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
    _firestore.collection('questions').doc();

    await ref.set({
      'id': ref.id,

      // Owner
      'teacherId': teacherId,

      // Question data
      'subject': subject.trim(),
      'difficulty': difficulty.toLowerCase(),
      'questionText': questionText.trim(),
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation.trim(),

      // Optional image will be connected later
      'imageUrl': null,

      // Dates
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  Future<void> updateQuestion({
    required String questionId,
    required String subject,
    required String difficulty,
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) async {
    await _firestore
        .collection('questions')
        .doc(questionId)
        .update({
      'subject': subject.trim(),
      'difficulty': difficulty.toLowerCase(),
      'questionText': questionText.trim(),
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteQuestion(
      String questionId,
      ) async {
    await _firestore
        .collection('questions')
        .doc(questionId)
        .delete();
  }

  // =========================================================
  // QUIZZES
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> teacherQuizzesStream(
      String teacherId,
      ) {
    return _firestore
        .collection('quizzes')
        .where(
      'teacherId',
      isEqualTo: teacherId,
    )
        .snapshots();
  }

  Future<String> createQuiz({
    required String teacherId,
    required String title,
    required String description,
    required String subject,
    required String quizType,
    required int durationMinutes,
    required int passingPercentage,
    required String classBatch,
    required List<String> questionIds,
    required bool leaderboardVisible,
  }) async {
    final quizRef =
    _firestore.collection('quizzes').doc();

    final String normalizedType =
    quizType.trim().toLowerCase();

    final String status =
    normalizedType == 'official'
        ? 'pending_approval'
        : 'draft';

    final WriteBatch batch =
    _firestore.batch();

    // ========================================================
    // CREATE QUIZ
    // ========================================================

    batch.set(
      quizRef,
      {
        'id': quizRef.id,
        'teacherId': teacherId,
        'title': title.trim(),
        'description': description.trim(),
        'subject': subject.trim(),
        'quizType': normalizedType,
        'durationMinutes': durationMinutes,
        'passingPercentage': passingPercentage,
        'classBatch': classBatch.trim(),
        'questionIds': questionIds,
        'status': status,
        'leaderboardVisible': leaderboardVisible,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // OFFICIAL QUIZ -> CONTROLLER NOTIFICATION
    // ========================================================

    if (normalizedType == 'official') {
      final notificationRef =
      _firestore
          .collection('notifications')
          .doc();

      batch.set(
        notificationRef,
        {
          'id': notificationRef.id,
          'type': 'official_quiz_pending',
          'audienceRole': 'controller',

          'quizId': quizRef.id,
          'teacherId': teacherId,

          'title': 'Official Quiz Pending',

          'message':
          '${title.trim()} is waiting for approval.',

          'isRead': false,

          'createdAt':
          FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();

// PHONE PUSH:
// Official quiz waiting for Controller approval
    if (normalizedType == 'official') {
      await PushNotificationService
          .sendOfficialQuizPendingPush(
        quizId:
        quizRef.id,

        quizTitle:
        title.trim(),
      );
    }

    return quizRef.id;
  }
  Future<bool> publishPracticeQuiz(
      String quizId,
      ) async {
    final quizRef =
    _firestore
        .collection('quizzes')
        .doc(quizId);

    final snapshot =
    await quizRef.get();

    if (!snapshot.exists) {
      throw Exception(
        'Quiz not found.',
      );
    }

    final data =
    snapshot.data()!;

    final String type =
        data['quizType']
            ?.toString()
            .toLowerCase() ??
            '';

    if (type != 'practice') {
      throw Exception(
        'Official quizzes must be published by the controller.',
      );
    }

    final String classBatch =
        data['classBatch']
            ?.toString()
            .trim() ??
            '';

    final String quizTitle =
        data['title']
            ?.toString()
            .trim() ??
            'Practice Quiz';

    final notificationRef =
    _firestore
        .collection('notifications')
        .doc();

    final batch =
    _firestore.batch();

    // ========================================================
    // PUBLISH QUIZ
    // ========================================================

    batch.update(
      quizRef,
      {
        'status':
        'published',

        'publishedAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // IN-APP FIRESTORE NOTIFICATION
    // ========================================================

    batch.set(
      notificationRef,
      {
        'id':
        notificationRef.id,

        'type':
        'practice_quiz_available',

        'audienceRole':
        'student',

        'quizId':
        quizId,

        'teacherId':
        data['teacherId'],

        'classBatch':
        classBatch,

        'title':
        'New Practice Quiz',

        'message':
        '$quizTitle is now available.',

        'readBy':
        <String>[],

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    // First save Firestore changes.
    await batch.commit();

    // ========================================================
    // PHONE PUSH VIA ONESIGNAL
    // ========================================================

    final pushSent =
    await PushNotificationService
        .sendPracticeQuizPush(
      classBatch:
      classBatch,

      quizId:
      quizId,

      quizTitle:
      quizTitle,
    );

    return pushSent;
  }
  Future<void> closeQuiz(
      String quizId,
      ) async {
    final quizRef =
    _firestore
        .collection('quizzes')
        .doc(quizId);

    final snapshot =
    await quizRef.get();

    if (!snapshot.exists) {
      throw Exception(
        'Quiz not found.',
      );
    }

    final data =
    snapshot.data()!;

    final String quizType =
        data['quizType']
            ?.toString()
            .toLowerCase() ??
            '';

    final String quizTitle =
        data['title']
            ?.toString()
            .trim() ??
            'Practice Quiz';

    // ========================================================
    // CLOSE QUIZ
    // ========================================================

    await quizRef.update({
      'status':
      'closed',

      'closedAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    });

    // ========================================================
    // PRACTICE QUIZ CLOSED -> STUDENT PHONE PUSH
    // ========================================================

    if (quizType == 'practice') {
      await PushNotificationService
          .sendPracticeQuizClosedPush(
        quizId:
        quizId,

        quizTitle:
        quizTitle,
      );
    }
  }

  // =========================================================
  // ATTEMPTS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> teacherAttemptsStream(
      String teacherId,
      ) {
    return _firestore
        .collection('attempts')
        .where(
      'teacherId',
      isEqualTo: teacherId,
    )
        .snapshots();
  }

  // Attempts for one specific quiz
  Stream<QuerySnapshot<Map<String, dynamic>>> quizAttemptsStream({
    required String teacherId,
    required String quizId,
  }) {
    return _firestore
        .collection('attempts')
        .where(
      'teacherId',
      isEqualTo: teacherId,
    )
        .where(
      'quizId',
      isEqualTo: quizId,
    )
        .snapshots();
  }
// ==========================================================
// CONTROLLER PROFILE
// ==========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> controllerProfileStream(
      String controllerId,
      ) {
    return _firestore
        .collection('controller')
        .doc(controllerId)
        .snapshots();
  }


// ==========================================================
// ALL STUDENTS
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> allStudentsStream() {
    return _firestore
        .collection('student')
        .snapshots();
  }


// ==========================================================
// ALL TEACHERS
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> allTeachersStream() {
    return _firestore
        .collection('teacher')
        .snapshots();
  }


// ==========================================================
// OFFICIAL EXAMS
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> officialExamsStream() {
    return _firestore
        .collection('quizzes')
        .where(
      'quizType',
      isEqualTo: 'official',
    )
        .snapshots();
  }


// ==========================================================
// ONE QUIZ
// ==========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> quizStream(
      String quizId,
      ) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .snapshots();
  }


// ==========================================================
// ATTEMPTS FOR ONE QUIZ
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> attemptsForQuizStream(
      String quizId,
      ) {
    return _firestore
        .collection('attempts')
        .where(
      'quizId',
      isEqualTo: quizId,
    )
        .snapshots();
  }


// ==========================================================
// CONTROLLER ACTIVITY
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> controllerActivityStream() {
    return _firestore
        .collection('activity_logs')
        .orderBy(
      'createdAt',
      descending: true,
    )
        .limit(20)
        .snapshots();
  }


// ==========================================================
// APPROVE + PUBLISH OFFICIAL EXAM
// ==========================================================

  Future<void> approveOfficialQuiz({
    required String quizId,
    required String controllerId,
    required String quizTitle,
  }) async {
    final quizRef =
    _firestore
        .collection('quizzes')
        .doc(quizId);

    final snapshot =
    await quizRef.get();

    if (!snapshot.exists) {
      throw Exception(
        'Exam not found.',
      );
    }

    final quiz =
    snapshot.data()!;

    final logRef =
    _firestore
        .collection('activity_logs')
        .doc();

    final notificationRef =
    _firestore
        .collection('notifications')
        .doc();

    final batch =
    _firestore.batch();

    batch.update(
      quizRef,
      {
        'status': 'published',
        'approvedBy':
        controllerId,
        'approvedAt':
        FieldValue.serverTimestamp(),
        'publishedAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      logRef,
      {
        'type':
        'exam_published',
        'controllerId':
        controllerId,
        'quizId': quizId,
        'message':
        '$quizTitle was approved and published.',
        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      notificationRef,
      {
        'id': notificationRef.id,
        'type':
        'official_exam_published',
        'audienceRole':
        'student',
        'quizId': quizId,
        'classBatch':
        quiz['classBatch'] ?? '',
        'title':
        'Official Exam Available',
        'message':
        '$quizTitle is now available.',
        'readBy': <String>[],
        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
    await PushNotificationService
        .sendOfficialExamPublishedPush(
      classBatch:
      quiz['classBatch']
          ?.toString() ??
          '',

      quizId:
      quizId,

      quizTitle:
      quizTitle,
    );
  }
// ==========================================================
// REJECT OFFICIAL EXAM
// ==========================================================

  Future<void> rejectOfficialQuiz({
    required String quizId,
    required String controllerId,
    required String quizTitle,
  }) async {
    final quizRef =
    _firestore
        .collection('quizzes')
        .doc(quizId);

    final logRef =
    _firestore
        .collection('activity_logs')
        .doc();

    final batch =
    _firestore.batch();

    // ========================================================
    // REJECT OFFICIAL EXAM
    // ========================================================

    batch.update(
      quizRef,
      {
        'status':
        'rejected',

        'rejectedBy':
        controllerId,

        'rejectedAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // ACTIVITY LOG
    // ========================================================

    batch.set(
      logRef,
      {
        'type':
        'exam_rejected',

        'controllerId':
        controllerId,

        'quizId':
        quizId,

        'message':
        '$quizTitle was rejected.',

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    // ========================================================
    // CONTROLLER -> SPECIFIC TEACHER PUSH
    // ========================================================

    await PushNotificationService
        .sendOfficialQuizRejectedPush(
      quizId:
      quizId,

      quizTitle:
      quizTitle,
    );
  }
// ==========================================================
// LOCK EXAM
// ==========================================================

  Future<void> lockOfficialQuiz({
    required String quizId,
    required String controllerId,
    required String quizTitle,
  }) async {
    final quizRef =
    _firestore.collection('quizzes').doc(quizId);

    final logRef =
    _firestore.collection('activity_logs').doc();

    final batch = _firestore.batch();

    batch.update(quizRef, {
      'status': 'locked',
      'lockedBy': controllerId,
      'lockedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(logRef, {
      'type': 'exam_locked',
      'controllerId': controllerId,
      'quizId': quizId,
      'message': '$quizTitle was locked.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }


// ==========================================================
// RELEASE RESULTS
// ==========================================================
  Future<void> releaseOfficialResults({
    required String quizId,
    required String controllerId,
    required String quizTitle,
  }) async {
    final quizRef =
    _firestore
        .collection('quizzes')
        .doc(quizId);

    final quizSnapshot =
    await quizRef.get();

    if (!quizSnapshot.exists) {
      throw Exception(
        'Exam not found.',
      );
    }

    final quiz =
    quizSnapshot.data()!;

    // Get all submitted attempts for this exam.
    final attemptSnapshot =
    await _firestore
        .collection('attempts')
        .where(
      'quizId',
      isEqualTo: quizId,
    )
        .get();

    final logRef =
    _firestore
        .collection('activity_logs')
        .doc();

    final notificationRef =
    _firestore
        .collection('notifications')
        .doc();

    final batch =
    _firestore.batch();

    // ========================================================
    // RELEASE EXAM RESULTS
    // ========================================================

    batch.update(
      quizRef,
      {
        'status':
        'results_released',

        'resultsReleasedBy':
        controllerId,

        'resultsReleasedAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // UNLOCK EVERY STUDENT RESULT
    // ========================================================

    for (final attemptDoc
    in attemptSnapshot.docs) {
      final attempt =
      attemptDoc.data();

      final String attemptStatus =
          attempt['status']
              ?.toString()
              .toLowerCase() ??
              '';

      // Only release completed/submitted attempts.
      // Never release a reopened or in-progress attempt.
      if (attemptStatus != 'submitted') {
        continue;
      }

      batch.update(
        attemptDoc.reference,
        {
          'resultReleased':
          true,

          'resultReleasedAt':
          FieldValue.serverTimestamp(),

          'resultReleasedBy':
          controllerId,

          'updatedAt':
          FieldValue.serverTimestamp(),
        },
      );
    }

    // ========================================================
    // ACTIVITY LOG
    // ========================================================

    batch.set(
      logRef,
      {
        'type':
        'results_released',

        'controllerId':
        controllerId,

        'quizId':
        quizId,

        'message':
        '$quizTitle results were released.',

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // STUDENT NOTIFICATION
    // ========================================================

    batch.set(
      notificationRef,
      {
        'id':
        notificationRef.id,

        'type':
        'official_results_released',

        'audienceRole':
        'student',

        'quizId':
        quizId,

        'classBatch':
        quiz['classBatch'] ?? '',

        'title':
        'Results Released',

        'message':
        '$quizTitle results are now available.',

        'readBy':
        <String>[],

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    await PushNotificationService
        .sendOfficialResultsReleasedPush(
      classBatch:
      quiz['classBatch']
          ?.toString() ??
          '',

      quizId:
      quizId,

      quizTitle:
      quizTitle,
    );
  }

// ==========================================================
// REOPEN STUDENT ATTEMPT
// ==========================================================

  Future<void> reopenAttempt({
    required String attemptId,
    required String controllerId,
    required String studentName,
    required String quizTitle,
    required String reason,
  }) async {
    final attemptRef = _firestore
        .collection('attempts')
        .doc(attemptId);

    final attemptSnapshot =
    await attemptRef.get();

    if (!attemptSnapshot.exists) {
      throw Exception('Attempt not found.');
    }

    final oldData =
        attemptSnapshot.data() ?? {};

    final logRef = _firestore
        .collection('activity_logs')
        .doc();

    final batch = _firestore.batch();

    // ========================================================
    // REOPEN SAME ATTEMPT
    // ========================================================

    batch.update(
      attemptRef,
      {
        // Save previous result for record/audit
        'previousScore':
        oldData['score'],

        'previousPercentage':
        oldData['percentage'],

        'previousTimeTakenSeconds':
        oldData['timeTakenSeconds'],

        // Student dashboard can now detect this
        'status': 'reopened',

        'reopened': true,

        'reopenedBy':
        controllerId,

        'reopenReason':
        reason.trim(),

        'reopenedAt':
        FieldValue.serverTimestamp(),

        'reopenCount':
        FieldValue.increment(1),

        // Reset previous submitted result
        'answers':
        <String, dynamic>{},

        'score': null,

        'percentage': null,

        'timeTakenSeconds': 0,

        'submittedAt': null,

        // Official result should not remain visible
        'resultReleased': false,

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // ACTIVITY LOG
    // ========================================================

    batch.set(
      logRef,
      {
        'type': 'attempt_reopened',

        'controllerId':
        controllerId,

        'attemptId':
        attemptId,

        'message':
        '$studentName\'s attempt for $quizTitle was reopened.',

        'reason':
        reason.trim(),

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    // ========================================================
    // CONTROLLER -> STUDENT PUSH
    // ========================================================

    await PushNotificationService
        .sendAttemptReopenedPush(
      attemptId: attemptId,
      quizTitle: quizTitle,
    );
  }
  Future<void> startReopenedAttempt({
    required String attemptId,
  }) async {
    await _firestore
        .collection('attempts')
        .doc(attemptId)
        .update({
      'status': 'in_progress',

      'reopenedStartedAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }
// ==========================================================
// CONTROLLER NOTIFICATIONS
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  controllerNotificationsStream() {
    return _firestore
        .collection('notifications')
        .where(
      'audienceRole',
      isEqualTo: 'controller',
    )
        .snapshots();
  }


// ==========================================================
// MARK NOTIFICATION AS READ
// ==========================================================

  Future<void> markNotificationAsRead(
      String notificationId,
      ) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
      'readAt':
      FieldValue.serverTimestamp(),
    });
  }


// ==========================================================
// MARK ALL CONTROLLER NOTIFICATIONS AS READ
// ==========================================================

  Future<void>
  markAllControllerNotificationsAsRead() async {
    final snapshot =
    await _firestore
        .collection('notifications')
        .where(
      'audienceRole',
      isEqualTo: 'controller',
    )
        .get();

    final unread = snapshot.docs.where(
          (doc) =>
      doc.data()['isRead'] != true,
    );

    if (unread.isEmpty) {
      return;
    }

    final batch =
    _firestore.batch();

    for (final doc in unread) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
          'readAt':
          FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }
  // ==========================================================
// STUDENT PROFILE
// ==========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>>
  studentProfileStream(
      String studentId,
      ) {
    return _firestore
        .collection('student')
        .doc(studentId)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>>
  getStudentProfile(
      String studentId,
      ) {
    return _firestore
        .collection('student')
        .doc(studentId)
        .get();
  }


// ==========================================================
// STUDENT QUIZZES
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> studentQuizzesStream(
      String classBatch,
      ) {
    return _firestore
        .collection('quizzes')
        .where(
      'classBatch',
      isEqualTo: classBatch,
    )
        .where(
      'status',
      isEqualTo: 'published',
    )
        .snapshots();
  }
// ==========================================================
// GET QUIZ
// ==========================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
  getQuiz(
      String quizId,
      ) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .get();
  }


// ==========================================================
// GET QUESTIONS IN QUIZ ORDER
// ==========================================================

  Future<List<Map<String, dynamic>>>
  getQuestionsByIds(
      List<String> questionIds,
      ) async {
    final List<Map<String, dynamic>>
    questions = [];

    for (final id in questionIds) {
      final snapshot =
      await _firestore
          .collection('questions')
          .doc(id)
          .get();

      if (snapshot.exists &&
          snapshot.data() != null) {
        questions.add({
          'id': snapshot.id,
          ...snapshot.data()!,
        });
      }
    }

    return questions;
  }


// ==========================================================
// CREATE STUDENT ATTEMPT
// ==========================================================

  Future<String> createStudentAttempt({
    required String studentId,
    required String quizId,
  }) async {
    final quizSnapshot =
    await getQuiz(quizId);

    if (!quizSnapshot.exists) {
      throw Exception(
        'Quiz not found.',
      );
    }

    final quiz =
    quizSnapshot.data()!;

    final String quizType =
        quiz['quizType']
            ?.toString()
            .toLowerCase() ??
            'practice';

    // Official exam = one attempt only
    if (quizType == 'official') {
      final previous =
      await _firestore
          .collection('attempts')
          .where(
        'studentId',
        isEqualTo: studentId,
      )
          .get();

      final existing =
      previous.docs.any(
            (doc) =>
        doc.data()['quizId'] ==
            quizId,
      );

      if (existing) {
        throw Exception(
          'You already attempted this official exam.',
        );
      }
    }

    final studentSnapshot =
    await getStudentProfile(
      studentId,
    );

    final student =
        studentSnapshot.data() ?? {};

    final ref =
    _firestore
        .collection('attempts')
        .doc();

    await ref.set({
      'id': ref.id,
      'quizId': quizId,
      'quizTitle':
      quiz['title'] ?? 'Quiz',
      'quizType': quizType,
      'teacherId':
      quiz['teacherId'],
      'studentId': studentId,
      'studentName':
      student['name'] ??
          'Student',
      'classBatch':
      quiz['classBatch'] ?? '',
      'status': 'in_progress',
      'answers': <String, int>{},
      'flaggedQuestionIds':
      <String>[],
      'score': 0,
      'percentage': 0,
      'timeTakenSeconds': 0,
      'resultReleased':
      quizType == 'practice',
      'startedAt':
      FieldValue.serverTimestamp(),
      'updatedAt':
      FieldValue.serverTimestamp(),
    });

    return ref.id;
  }


// ==========================================================
// SUBMIT ATTEMPT
// ==========================================================

  Future<void> submitStudentAttempt({
    required String attemptId,
    required Map<String, int> answers,
    required List<String> flaggedQuestionIds,
    required int score,
    required int percentage,
    required int timeTakenSeconds,
  }) async {
    final attemptRef =
    _firestore
        .collection('attempts')
        .doc(attemptId);

    final attemptSnapshot =
    await attemptRef.get();

    if (!attemptSnapshot.exists) {
      throw Exception(
        'Attempt not found.',
      );
    }

    final attempt =
    attemptSnapshot.data()!;

    final String quizType =
        attempt['quizType']
            ?.toString()
            .toLowerCase() ??
            'practice';

    final bool isOfficial =
        quizType == 'official';

    final batch =
    _firestore.batch();

    // ========================================================
    // SUBMIT ATTEMPT
    // ========================================================

    batch.update(
      attemptRef,
      {
        'answers': answers,

        'flaggedQuestionIds':
        flaggedQuestionIds,

        'score': score,

        'percentage':
        percentage,

        'timeTakenSeconds':
        timeTakenSeconds,

        'status':
        'submitted',

        // Practice → immediately available
        // Official → wait for Controller
        'resultReleased':
        !isOfficial,

        'submittedAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ========================================================
    // OFFICIAL EXAM -> NOTIFY CONTROLLER
    // ========================================================

    if (isOfficial) {
      final notificationRef =
      _firestore
          .collection('notifications')
          .doc();

      final String studentName =
          attempt['studentName']
              ?.toString() ??
              'A student';

      final String quizTitle =
          attempt['quizTitle']
              ?.toString() ??
              'Official Exam';

      batch.set(
        notificationRef,
        {
          'id':
          notificationRef.id,

          'type':
          'official_attempt_submitted',

          'audienceRole':
          'controller',

          'quizId':
          attempt['quizId'],

          'attemptId':
          attemptId,

          'studentId':
          attempt['studentId'],

          'studentName':
          studentName,

          'title':
          'Official Exam Completed',

          'message':
          '$studentName completed $quizTitle. Result is ready for release.',

          'isRead':
          false,

          'createdAt':
          FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
    if (isOfficial) {
      final String studentName =
          attempt['studentName']
              ?.toString() ??
              'A student';

      final String quizTitle =
          attempt['quizTitle']
              ?.toString() ??
              'Official Exam';

      await PushNotificationService
          .sendOfficialAttemptSubmittedPush(
        quizId:
        attempt['quizId']
            ?.toString() ??
            '',

        studentName:
        studentName,

        quizTitle:
        quizTitle,
      );
    }
  }

// ==========================================================
// STUDENT ATTEMPT
// ==========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>>
  studentAttemptStream(
      String attemptId,
      ) {
    return _firestore
        .collection('attempts')
        .doc(attemptId)
        .snapshots();
  }


// ==========================================================
// STUDENT HISTORY
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  studentAttemptsStream(
      String studentId,
      ) {
    return _firestore
        .collection('attempts')
        .where(
      'studentId',
      isEqualTo: studentId,
    )
        .snapshots();
  }


// ==========================================================
// STUDENT NOTIFICATIONS
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> studentNotificationsStream(
      String classBatch,
      ) {
    return _firestore
        .collection('notifications')
        .where(
      'audienceRole',
      isEqualTo: 'student',
    )
        .where(
      'classBatch',
      isEqualTo: classBatch,
    )
        .snapshots();
  }
  Future<void>
  markStudentNotificationRead({
    required String notificationId,
    required String studentId,
  }) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({
      'readBy':
      FieldValue.arrayUnion([
        studentId,
      ]),
    });
  }


// ==========================================================
// WEAK TOPICS
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  studentWeakTopicsStream(
      String studentId,
      ) {
    return _firestore
        .collection('weak_topics')
        .where(
      'studentId',
      isEqualTo: studentId,
    )
        .snapshots();
  }

  Future<void> saveWeakTopic({
    required String studentId,
    required String questionId,
    required String subject,
    required String questionText,
    required String explanation,
  }) async {
    final docId =
        '${studentId}_$questionId';

    await _firestore
        .collection('weak_topics')
        .doc(docId)
        .set({
      'studentId': studentId,
      'questionId': questionId,
      'subject': subject,
      'questionText':
      questionText,
      'explanation':
      explanation,
      'createdAt':
      FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeWeakTopic({
    required String studentId,
    required String questionId,
  }) async {
    await _firestore
        .collection('weak_topics')
        .doc(
      '${studentId}_$questionId',
    )
        .delete();
  }
  // ==========================================================
// PRACTICE LEADERBOARD
// ==========================================================

// ==========================================================
// LEADERBOARD ATTEMPTS
// Practice + Official
// ==========================================================
// ==========================================================
// LEADERBOARD ATTEMPTS
// Practice + Official
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  leaderboardAttemptsStream({
    required String quizId,
    required String classBatch,
  }) {
    return _firestore
        .collection('attempts')
        .where(
      'quizId',
      isEqualTo: quizId,
    )
        .where(
      'status',
      isEqualTo: 'submitted',
    )
        .where(
      'classBatch',
      isEqualTo: classBatch,
    )
        .where(
      'resultReleased',
      isEqualTo: true,
    )
        .snapshots();
  }
  // ==========================================================
// QUIZZES AVAILABLE FOR LEADERBOARD
// ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
  studentLeaderboardQuizzesStream(
      String classBatch,
      ) {
    return _firestore
        .collection('quizzes')
        .where(
      'classBatch',
      isEqualTo: classBatch,
    )
        .where(
      'leaderboardVisible',
      isEqualTo: true,
    )
        .where(
      'status',
      whereIn: [
        'published',
        'closed',
        'results_released',
        'locked',
      ],
    )
        .snapshots();
  }

// ==========================================================
// EDIT STUDENT PROFILE
// ==========================================================

  Future<void> updateStudentProfile({
    required String studentId,
    required String name,
  }) async {
    await _firestore
        .collection('student')
        .doc(studentId)
        .update({
      'name': name.trim(),
      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }

// ==========================================================
// DELETE TEACHER QUIZ
// ==========================================================

  Future<void> deleteQuiz(
      String quizId,
      ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'You are not logged in.',
      );
    }

    final quizRef =
    _firestore
        .collection('quizzes')
        .doc(quizId);

    final quizSnapshot =
    await quizRef.get();

    if (!quizSnapshot.exists) {
      throw Exception(
        'Quiz not found.',
      );
    }

    final quiz =
    quizSnapshot.data()!;

    final String teacherId =
        quiz['teacherId']
            ?.toString() ??
            '';

    // ========================================================
    // VERIFY OWNERSHIP
    // ========================================================

    if (teacherId != user.uid) {
      throw Exception(
        'You cannot delete another teacher\'s quiz.',
      );
    }

    // ========================================================
    // CHECK STUDENT ATTEMPTS
    //
    // IMPORTANT:
    // teacherId MUST be included because Firestore rules
    // only allow the teacher to read their own attempts.
    // ========================================================

    final attemptsSnapshot =
    await _firestore
        .collection('attempts')
        .where(
      'teacherId',
      isEqualTo: user.uid,
    )
        .where(
      'quizId',
      isEqualTo: quizId,
    )
        .limit(1)
        .get();

    // ========================================================
    // DON'T DELETE USED QUIZZES
    // ========================================================

    if (attemptsSnapshot.docs.isNotEmpty) {
      throw Exception(
        'This quiz already has student attempts. Close it instead so student results and history are preserved.',
      );
    }

    // ========================================================
    // DELETE QUIZ FROM FIRESTORE
    // ========================================================

    await quizRef.delete();
  }

  Future<void> updateTeacherProfile({
    required String teacherId,
    required String name,
    required String departmentCourse,
    required String campus,
  }) async {
    await _firestore
        .collection('teacher')
        .doc(teacherId)
        .update({
      'name': name.trim(),
      'departmentCourse':
      departmentCourse.trim(),
      'campus': campus.trim(),
      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }
  Future<void> updateControllerProfile({
    required String controllerId,
    required String name,
    required String designation,
    required String campus,
  }) async {
    await _firestore
        .collection('controller')
        .doc(controllerId)
        .update({
      'name':
      name.trim(),

      'designation':
      designation.trim(),

      'campus':
      campus.trim(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }
  Future<void> deleteStudentNotification(
      String notificationId,
      ) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
  // ==========================================================
// RELEASE ONE REOPENED STUDENT RESULT
// ==========================================================

  Future<void> releaseSingleAttemptResult({
    required String attemptId,
    required String controllerId,
    required String studentName,
    required String quizTitle,
  }) async {
    final attemptRef =
    _firestore
        .collection('attempts')
        .doc(attemptId);

    final attemptSnapshot =
    await attemptRef.get();

    if (!attemptSnapshot.exists) {
      throw Exception(
        'Attempt not found.',
      );
    }

    final attempt =
    attemptSnapshot.data()!;

    final String status =
        attempt['status']
            ?.toString()
            .toLowerCase() ??
            '';

    final String quizType =
        attempt['quizType']
            ?.toString()
            .toLowerCase() ??
            '';

    final bool reopened =
        attempt['reopened'] == true;

    final bool alreadyReleased =
        attempt['resultReleased'] == true;

    // ----------------------------------------------------------
    // VALIDATE ATTEMPT
    // ----------------------------------------------------------

    if (quizType != 'official') {
      throw Exception(
        'Only official exam results can be released here.',
      );
    }

    if (!reopened) {
      throw Exception(
        'This is not a reopened attempt.',
      );
    }

    if (status != 'submitted') {
      throw Exception(
        'The student must submit the reopened attempt first.',
      );
    }

    if (alreadyReleased) {
      throw Exception(
        'This result is already released.',
      );
    }

    final String quizId =
        attempt['quizId']
            ?.toString() ??
            '';

    if (quizId.isEmpty) {
      throw Exception(
        'Quiz information is missing.',
      );
    }

    // ----------------------------------------------------------
    // VERIFY THAT GENERAL EXAM RESULTS WERE ALREADY RELEASED
    // ----------------------------------------------------------

    final quizSnapshot =
    await _firestore
        .collection('quizzes')
        .doc(quizId)
        .get();

    if (!quizSnapshot.exists) {
      throw Exception(
        'Exam not found.',
      );
    }

    final quiz =
    quizSnapshot.data()!;

    final String quizStatus =
        quiz['status']
            ?.toString()
            .toLowerCase() ??
            '';

    if (quizStatus !=
        'results_released') {
      throw Exception(
        'Release the overall exam results first.',
      );
    }

    final logRef =
    _firestore
        .collection('activity_logs')
        .doc();

    final batch =
    _firestore.batch();

    // ----------------------------------------------------------
    // RELEASE ONLY THIS STUDENT RESULT
    // ----------------------------------------------------------

    batch.update(
      attemptRef,
      {
        'resultReleased':
        true,

        'resultReleasedBy':
        controllerId,

        'resultReleasedAt':
        FieldValue.serverTimestamp(),

        'reopenedResultReleased':
        true,

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ----------------------------------------------------------
    // ACTIVITY LOG
    // ----------------------------------------------------------

    batch.set(
      logRef,
      {
        'type':
        'reopened_result_released',

        'controllerId':
        controllerId,

        'quizId':
        quizId,

        'attemptId':
        attemptId,

        'studentId':
        attempt['studentId'],

        'studentName':
        studentName,

        'message':
        '$studentName\'s reopened result for $quizTitle was released.',

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }
}