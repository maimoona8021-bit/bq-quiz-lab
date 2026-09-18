import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class ResultScreen extends StatelessWidget {
  final String attemptId;
  final String quizId;

  const ResultScreen({
    super.key,
    required this.attemptId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Result',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: firestore.studentAttemptStream(
          attemptId,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data();

          final bool hiddenOfficial =
              data?['quizType'] == 'official' &&
                  data?['resultReleased'] != true;

          if (hiddenOfficial) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE8EDF4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_clock_rounded,
                          size: 36,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Result Held',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your result will be available after the Exam Controller releases it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.student,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.studentDashboard,
                                  (_) => false,
                            );
                          },
                          child: const Text(
                            'Back Home',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (data == null) {
            return const Center(
              child: Text(
                'Result not found.',
              ),
            );
          }

          final percentage =
              (data['percentage'] as num?)?.round() ?? 0;

          final passed = percentage >= 60;

          final score = data['score'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            child: Column(
              children: [
                const SizedBox(height: 6),

                Text(
                  data['quizTitle']?.toString() ?? 'Quiz Result',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  passed
                      ? 'Great job! Here is your performance summary.'
                      : 'Here is your performance summary.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================
                // RESULT CIRCLE CARD
                // ==========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE8EDF4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.035),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 170,
                              height: 170,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 12,
                                backgroundColor:
                                const Color(0xFFE7ECF3),
                                color: passed
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$percentage%',
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  passed ? 'Score' : 'Result',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: passed
                              ? Colors.green.withOpacity(.10)
                              : Colors.red.withOpacity(.10),
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                        child: Text(
                          passed ? 'PASSED' : 'FAILED',
                          style: TextStyle(
                            color: passed
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==========================
                // STATS
                // ==========================
                Row(
                  children: [
                    Expanded(
                      child: _ResultStat(
                        icon: Icons.check_circle_outline_rounded,
                        value: '$score',
                        label: 'Correct',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResultStat(
                        icon: Icons.schedule_rounded,
                        value:
                        '${(data['timeTakenSeconds'] ?? 0) ~/ 60} min',
                        label: 'Time Used',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ==========================
                // REVIEW ANSWERS
                // ==========================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.student,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.answerReview,
                        arguments: {
                          'attemptId': attemptId,
                          'quizId': quizId,
                        },
                      );
                    },
                    child: const Text(
                      'Review Answers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

// ======================================================
// LEADERBOARD
// Practice + Official
// Only shown when enabled
// Official only after results are released
// ======================================================

                StreamBuilder<
                    DocumentSnapshot<Map<String, dynamic>>>(
                  stream: firestore.quizStream(
                    quizId,
                  ),
                  builder: (context, quizSnapshot) {
                    if (!quizSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final quizData =
                        quizSnapshot.data?.data() ?? {};

                    final bool leaderboardVisible =
                        quizData['leaderboardVisible'] == true;

                    final String quizType =
                        quizData['quizType']
                            ?.toString()
                            .toLowerCase() ??
                            'practice';

                    final String status =
                        quizData['status']
                            ?.toString()
                            .toLowerCase() ??
                            '';

                    // Teacher did not enable leaderboard.
                    if (!leaderboardVisible) {
                      return const SizedBox.shrink();
                    }

                    // Official leaderboard must wait
                    // until Controller releases results.
                    if (quizType == 'official' &&
                        status != 'results_released') {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.practiceLeaderboard,
                            arguments: quizId,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(
                            color: Color(0xFFDCE3EC),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFF59E0B),
                        ),
                        label: Text(
                          quizType == 'official'
                              ? 'View Official Leaderboard'
                              : 'View Leaderboard',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),

// ======================================================
// PRACTICE AGAIN
// Only Practice quizzes can be attempted again
// ======================================================

                if (data['quizType'] == 'practice') ...[
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.examRules,
                              (route) => route.isFirst,
                          arguments: quizId,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.student,
                        side: const BorderSide(
                          color: Color(0xFFDCE3EC),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'Practice Again',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.studentDashboard,
                            (_) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                    ),
                    child: const Text(
                      'Back Home',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.student.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.student,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}