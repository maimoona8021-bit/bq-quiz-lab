import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class AnswerReviewScreen extends StatefulWidget {
  final String attemptId;
  final String quizId;

  const AnswerReviewScreen({
    super.key,
    required this.attemptId,
    required this.quizId,
  });

  @override
  State<AnswerReviewScreen> createState() =>
      _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends State<AnswerReviewScreen> {
  final FirestoreService _firestore = FirestoreService();

  bool _loading = true;

  List<Map<String, dynamic>> _questions = [];

  Map<String, dynamic> _attempt = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quiz = await _firestore.getQuiz(
      widget.quizId,
    );

    final attempt = await FirebaseFirestore.instance
        .collection('attempts')
        .doc(widget.attemptId)
        .get();

    final quizData = quiz.data() ?? {};

    final questions = await _firestore.getQuestionsByIds(
      List<String>.from(
        quizData['questionIds'] ?? [],
      ),
    );

    if (!mounted) return;

    setState(() {
      _questions = questions;
      _attempt = attempt.data() ?? {};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final answers = Map<String, dynamic>.from(
      _attempt['answers'] ?? {},
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Answer Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          28,
        ),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];

          final id = question['id'].toString();

          final selected = answers[id];

          final correct = question['correctIndex'];

          final isCorrect = selected == correct;

          final options = List<String>.from(
            question['options'] ?? [],
          );

          return Container(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE4EAF1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.025),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================================
                // QUESTION HEADER
                // ========================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    15,
                    16,
                    0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                          AppColors.student.withOpacity(.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'QUESTION ${index + 1}',
                          style: const TextStyle(
                            color: AppColors.student,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                          ),
                        ),
                      ),

                      const Spacer(),

                      _StatusBadge(
                        correct: isCorrect,
                      ),
                    ],
                  ),
                ),

                // ========================================
                // QUESTION TEXT
                // ========================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16,
                  ),
                  child: Text(
                    question['questionText']?.toString() ?? '',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEDF1F5),
                ),

                // ========================================
                // ANSWERS
                // ========================================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _AnswerBox(
                        icon: isCorrect
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        label: 'Your answer',
                        value: selected == null
                            ? 'Not answered'
                            : options[selected],
                        color: selected == null
                            ? AppColors.textSecondary
                            : isCorrect
                            ? Colors.green
                            : Colors.red,
                      ),

                      const SizedBox(height: 10),

                      _AnswerBox(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Correct answer',
                        value: options[
                        (correct as num).toInt()],
                        color: Colors.green,
                      ),

                      const SizedBox(height: 14),

                      // ====================================
                      // EXPLANATION
                      // ====================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                          AppColors.student.withOpacity(.045),
                          borderRadius:
                          BorderRadius.circular(13),
                          border: Border.all(
                            color: AppColors.student
                                .withOpacity(.10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons
                                      .lightbulb_outline_rounded,
                                  color: AppColors.student,
                                  size: 18,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Explanation',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              question['explanation']
                                  ?.toString() ??
                                  'No explanation provided.',
                              style: const TextStyle(
                                color:
                                AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 13),

                      // ====================================
                      // BOOKMARK
                      // ====================================
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () => _bookmark(
                            question,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            side: const BorderSide(
                              color: Color(0xFFD9E1EA),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.bookmark_add_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Bookmark as Weak Topic',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _bookmark(
      Map<String, dynamic> question,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _firestore.saveWeakTopic(
      studentId: user.uid,
      questionId: question['id'].toString(),
      subject: question['subject']?.toString() ?? 'General',
      questionText:
      question['questionText']?.toString() ?? '',
      explanation:
      question['explanation']?.toString() ?? '',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Added to My Weak Topics.',
        ),
      ),
    );
  }
}

// ============================================================
// CORRECT / INCORRECT BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final bool correct;

  const _StatusBadge({
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    correct ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            correct ? 'CORRECT' : 'INCORRECT',
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ANSWER DISPLAY
// ============================================================

class _AnswerBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AnswerBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.045),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 17,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}