import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
  PushNotificationService._();

  static const String _workerUrl =
      'https://bq-quiz-notifications.maimoona8021.workers.dev';

  // =========================================================
  // GENERIC PUSH SENDER
  // =========================================================

  static Future<bool> _send({
    required String type,
    required String title,
    required String message,
    String? classBatch,
    String? quizId,
    String? attemptId,
  }) async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint(
          'PUSH ERROR: User not logged in.',
        );

        return false;
      }

      final token =
      await user.getIdToken(true);

      if (token == null) {
        debugPrint(
          'PUSH ERROR: Firebase token unavailable.',
        );

        return false;
      }

      final Map<String, dynamic> body = {
        'type': type,
        'senderUid': user.uid,
        'title': title,
        'message': message,
      };

      if (quizId != null &&
          quizId.trim().isNotEmpty) {
        body['quizId'] =
            quizId.trim();
      }

      if (attemptId != null &&
          attemptId.trim().isNotEmpty) {
        body['attemptId'] =
            attemptId.trim();
      }

      if (classBatch != null &&
          classBatch.trim().isNotEmpty) {
        body['classBatch'] =
            classBatch.trim();
      }

      final response =
      await http.post(
        Uri.parse(
          _workerUrl,
        ),
        headers: {
          'Content-Type':
          'application/json',

          'Authorization':
          'Bearer $token',
        },
        body:
        jsonEncode(body),
      );

      debugPrint(
        'PUSH [$type] STATUS: ${response.statusCode}',
      );

      debugPrint(
        'PUSH [$type] RESPONSE: ${response.body}',
      );

      return response.statusCode >=
          200 &&
          response.statusCode <
              300;
    } catch (e) {
      debugPrint(
        'PUSH [$type] EXCEPTION: $e',
      );

      return false;
    }
  }

  // =========================================================
  // PRACTICE QUIZ PUBLISHED
  // TEACHER -> STUDENTS
  // =========================================================

  static Future<bool>
  sendPracticeQuizPush({
    required String classBatch,
    required String quizId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'practice_quiz_published',

      classBatch:
      classBatch,

      quizId:
      quizId,

      title:
      'New Practice Quiz',

      message:
      '$quizTitle is now available.',
    );
  }

  // =========================================================
  // OFFICIAL QUIZ CREATED
  // TEACHER -> CONTROLLER
  // =========================================================

  static Future<bool>
  sendOfficialQuizPendingPush({
    required String quizId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'official_quiz_pending',

      quizId:
      quizId,

      title:
      'Official Quiz Pending',

      message:
      '$quizTitle is waiting for approval.',
    );
  }

  // =========================================================
  // OFFICIAL QUIZ PUBLISHED
  // CONTROLLER -> STUDENTS
  // =========================================================

  static Future<bool>
  sendOfficialExamPublishedPush({
    required String classBatch,
    required String quizId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'official_exam_published',

      classBatch:
      classBatch,

      quizId:
      quizId,

      title:
      'Official Exam Available',

      message:
      '$quizTitle is now available.',
    );
  }

  // =========================================================
  // OFFICIAL ATTEMPT SUBMITTED
  // STUDENT -> CONTROLLER
  // =========================================================

  static Future<bool>
  sendOfficialAttemptSubmittedPush({
    required String quizId,
    required String studentName,
    required String quizTitle,
  }) {
    return _send(
      type:
      'official_attempt_submitted',

      quizId:
      quizId,

      title:
      'Official Exam Completed',

      message:
      '$studentName completed $quizTitle.',
    );
  }

  // =========================================================
  // OFFICIAL RESULTS RELEASED
  // CONTROLLER -> STUDENTS
  // =========================================================

  static Future<bool>
  sendOfficialResultsReleasedPush({
    required String classBatch,
    required String quizId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'official_results_released',

      classBatch:
      classBatch,

      quizId:
      quizId,

      title:
      'Results Released',

      message:
      '$quizTitle results are now available.',
    );
  }

  // =========================================================
  // OFFICIAL QUIZ REJECTED
  // CONTROLLER -> SPECIFIC TEACHER
  // =========================================================

  static Future<bool>
  sendOfficialQuizRejectedPush({
    required String quizId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'official_quiz_rejected',

      quizId:
      quizId,

      title:
      'Official Exam Rejected',

      message:
      '$quizTitle was rejected by the Controller.',
    );
  }

  // =========================================================
  // ATTEMPT REOPENED
  // CONTROLLER -> SPECIFIC STUDENT
  // =========================================================

  static Future<bool>
  sendAttemptReopenedPush({
    required String attemptId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'official_attempt_reopened',

      attemptId:
      attemptId,

      title:
      'Attempt Reopened',

      message:
      'Your attempt for $quizTitle has been reopened.',
    );
  }

  // =========================================================
  // PRACTICE QUIZ CLOSED
  // TEACHER -> STUDENTS
  // =========================================================

  static Future<bool>
  sendPracticeQuizClosedPush({
    required String quizId,
    required String quizTitle,
  }) {
    return _send(
      type:
      'practice_quiz_closed',

      quizId:
      quizId,

      title:
      'Practice Quiz Closed',

      message:
      '$quizTitle is no longer accepting attempts.',
    );
  }
}