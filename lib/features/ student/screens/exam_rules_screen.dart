import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/firestore_service.dart';

class ExamRulesScreen extends StatefulWidget {
  final String quizId;

  const ExamRulesScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<ExamRulesScreen> createState() => _ExamRulesScreenState();
}

class _ExamRulesScreenState extends State<ExamRulesScreen> {
  final FirestoreService _firestore = FirestoreService();

  bool _accepted = false;
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Exam Rules',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: StreamBuilder(
        stream: _firestore.quizStream(widget.quizId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return const Center(
              child: Text('Quiz not found.'),
            );
          }

          final official = data['quizType'] == 'official';

          final questions = List.from(
            data['questionIds'] ?? [],
          ).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              28,
            ),
            children: [

              // ==============================
              // EXAM HEADER CARD
              // ==============================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(.12),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.student.withOpacity(.16),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppColors.student,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                              AppColors.student.withOpacity(.15),
                              borderRadius:
                              BorderRadius.circular(6),
                            ),
                            child: Text(
                              official
                                  ? 'OFFICIAL EXAM'
                                  : 'PRACTICE QUIZ',
                              style: const TextStyle(
                                color: AppColors.student,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .7,
                              ),
                            ),
                          ),

                          const SizedBox(height: 9),

                          Text(
                            data['title']?.toString() ?? 'Quiz',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            official
                                ? 'Read the instructions before starting'
                                : 'Review the rules before practice',
                            style: TextStyle(
                              color:
                              Colors.white.withOpacity(.65),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==============================
              // EXAM INFORMATION
              // ==============================
              const Text(
                'Exam Information',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 10),

              _Info(
                icon: Icons.quiz_outlined,
                label: 'Number of questions',
                value: '$questions MCQs',
              ),

              _Info(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value:
                '${data['durationMinutes'] ?? 0} minutes',
              ),

              _Info(
                icon: Icons.percent_rounded,
                label: 'Passing percentage',
                value:
                '${data['passingPercentage'] ?? 0}%',
              ),

              const SizedBox(height: 14),

              // ==============================
              // RULES CARD
              // ==============================
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withOpacity(.04),
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color:
                            AppColors.student.withOpacity(.09),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.rule_rounded,
                            color: AppColors.student,
                            size: 19,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exam Rules',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Please read carefully',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const _RuleRow(
                      icon: Icons.play_circle_outline_rounded,
                      text:
                      'Timer begins as soon as you start.',
                    ),

                    const _RuleRow(
                      icon: Icons.flag_outlined,
                      text:
                      'Questions may be flagged for review.',
                    ),

                    const _RuleRow(
                      icon: Icons.schedule_rounded,
                      text:
                      'The quiz automatically submits when time ends.',
                    ),

                    _RuleRow(
                      icon: official
                          ? Icons.lock_outline_rounded
                          : Icons.replay_rounded,
                      text: official
                          ? 'Official exams allow only one attempt.'
                          : 'Practice quizzes can be attempted again.',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==============================
              // ACCEPT RULES
              // ==============================
              Container(
                decoration: BoxDecoration(
                  color: _accepted
                      ? AppColors.student.withOpacity(.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _accepted
                        ? AppColors.student.withOpacity(.35)
                        : Colors.black.withOpacity(.05),
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  value: _accepted,
                  activeColor: AppColors.student,
                  checkColor: Colors.white,
                  controlAffinity:
                  ListTileControlAffinity.trailing,
                  title: const Text(
                    'I understand the exam rules',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      'Confirm before continuing',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _accepted = value ?? false;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ==============================
              // START BUTTON
              // ==============================
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.student,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    Colors.grey.shade300,
                    disabledForegroundColor:
                    Colors.grey.shade500,
                    elevation: _accepted ? 2 : 0,
                    shadowColor:
                    AppColors.student.withOpacity(.25),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: !_accepted || _starting
                      ? null
                      : () => _start(data),
                  child: _starting
                      ? const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 17,
                        height: 17,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Starting...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        official
                            ? 'Start Exam'
                            : 'Start Practice',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  official
                      ? 'Your attempt will begin immediately'
                      : 'You can practice again later',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // ORIGINAL FUNCTIONALITY — UNCHANGED
  // =========================================================

  Future<void> _start(
      Map<String, dynamic> quiz,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _starting = true;
    });

    try {
      final attemptId =
      await _firestore.createStudentAttempt(
        studentId: user.uid,
        quizId: widget.quizId,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.quizPlayer,
        arguments: {
          'quizId': widget.quizId,
          'attemptId': attemptId,
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _starting = false;
        });
      }
    }
  }
}

// =========================================================
// INFORMATION CARD
// =========================================================

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Info({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.black.withOpacity(.035),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.018),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.student.withOpacity(.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: AppColors.student,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// RULE ROW
// =========================================================

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;

  const _RuleRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: AppColors.student.withOpacity(.07),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 14,
              color: AppColors.student,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.35,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}