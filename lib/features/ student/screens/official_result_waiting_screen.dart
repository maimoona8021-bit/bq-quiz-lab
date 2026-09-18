import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class OfficialResultWaitingScreen extends StatelessWidget {
  final String attemptId;
  final String quizId;

  const OfficialResultWaitingScreen({
    super.key,
    required this.attemptId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder(
          stream: firestore.quizStream(
            quizId,
          ),
          builder: (context, snapshot) {
            final released =
                snapshot.hasData &&
                    snapshot.data!.data()?['status'] ==
                        'results_released';

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  24,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    28,
                    22,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE5EAF1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.035,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =====================================
                      // STATUS ICON
                      // =====================================
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: released
                              ? Colors.green.withValues(
                            alpha: 0.10,
                          )
                              : AppColors.student.withValues(
                            alpha: 0.08,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          released
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: released
                              ? Colors.green
                              : AppColors.student,
                          size: 42,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =====================================
                      // STATUS BADGE
                      // =====================================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: released
                              ? Colors.green.withValues(
                            alpha: 0.08,
                          )
                              : AppColors.student.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          released
                              ? 'RESULT AVAILABLE'
                              : 'RESULT PENDING',
                          style: TextStyle(
                            color: released
                                ? Colors.green.shade700
                                : AppColors.student,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =====================================
                      // TITLE
                      // =====================================
                      Text(
                        released
                            ? 'Results Released'
                            : 'Exam Submitted Successfully',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =====================================
                      // DESCRIPTION
                      // =====================================
                      Text(
                        released
                            ? 'Your official exam result is now available. You can view your score and performance details.'
                            : 'Your exam has been submitted successfully. The Exam Controller will release the official results when they are ready.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.55,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =====================================
                      // INFO BOX
                      // =====================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.student.withValues(
                            alpha: 0.045,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.student.withValues(
                              alpha: 0.10,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              released
                                  ? Icons.info_outline_rounded
                                  : Icons.notifications_none_rounded,
                              color: AppColors.student,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                released
                                    ? 'Your result has been officially released by the Exam Controller.'
                                    : 'You will be notified when the Exam Controller publishes the results.',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =====================================
                      // VIEW RESULT
                      // =====================================
                      if (released) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.student,
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shadowColor: AppColors.student.withValues(
                                alpha: 0.20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.result,
                                arguments: {
                                  'attemptId': attemptId,
                                  'quizId': quizId,
                                },
                              );
                            },
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 19,
                            ),
                            label: const Text(
                              'View Result',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // =====================================
                      // BACK HOME
                      // =====================================
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.studentDashboard,
                                  (_) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            side: const BorderSide(
                              color: Color(0xFFD8E0EA),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.home_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Back to Home',
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
              ),
            );
          },
        ),
      ),
    );
  }
}