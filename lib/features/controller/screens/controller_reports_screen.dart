import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../ widgets/controller_bottom_nav.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class ControllerReportsScreen extends StatefulWidget {
  final String? initialQuizId;

  const ControllerReportsScreen({
    super.key,
    this.initialQuizId,
  });

  @override
  State<ControllerReportsScreen> createState() =>
      _ControllerReportsScreenState();
}

class _ControllerReportsScreenState
    extends State<ControllerReportsScreen> {
  final FirestoreService _firestore = FirestoreService();

  String? _selectedQuizId;

  @override
  void initState() {
    super.initState();
    _selectedQuizId = widget.initialQuizId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: const ControllerBottomNav(
        currentIndex: 2,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                18,
              ),
              decoration: const BoxDecoration(
                color: AppColors.navy,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: AppColors.controller,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Reports',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore.officialExamsStream(),
                builder: (context, examSnapshot) {
                  if (!examSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.controller,
                      ),
                    );
                  }

                  final exams = examSnapshot.data!.docs;

                  if (exams.isEmpty) {
                    return const _NoOfficialExams();
                  }

                  if (_selectedQuizId == null ||
                      !exams.any(
                            (e) => e.id == _selectedQuizId,
                      )) {
                    _selectedQuizId = exams.first.id;
                  }

                  final selectedExam = exams.firstWhere(
                        (e) => e.id == _selectedQuizId,
                  );

                  final quizData = selectedExam.data();

                  final passing =
                      (quizData['passingPercentage'] as num?)
                          ?.toDouble() ??
                          60;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      28,
                    ),
                    children: [
                      // =================================================
                      // PAGE INTRO
                      // =================================================
                      const Text(
                        'Exam Performance',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Review class performance for published official exams.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // EXAM SELECTOR
                      // =================================================
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          10,
                          14,
                          10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFE5EAF1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.025,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedQuizId,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.controller,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Official Exam',
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            prefixIcon: Icon(
                              Icons.assignment_rounded,
                              color: AppColors.controller,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          items: exams
                              .map(
                                (doc) => DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                doc.data()['title']
                                    ?.toString() ??
                                    'Exam',
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedQuizId = value;
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // SELECTED EXAM HEADER
                      // =================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.controller
                                    .withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius:
                                BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                color: AppColors.controller,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'OFFICIAL EXAM REPORT',
                                    style: TextStyle(
                                      color: AppColors.controller,
                                      fontSize: 8,
                                      fontWeight:
                                      FontWeight.w700,
                                      letterSpacing: .7,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    quizData['title']
                                        ?.toString() ??
                                        'Exam Report',
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${quizData['subject'] ?? 'General'} • Pass ${passing.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Color(
                                        0xFFB4C0D2,
                                      ),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: _firestore
                            .attemptsForQuizStream(
                          _selectedQuizId!,
                        ),
                        builder: (
                            context,
                            attemptSnapshot,
                            ) {
                          if (!attemptSnapshot.hasData) {
                            return const Center(
                              child:
                              CircularProgressIndicator(
                                color:
                                AppColors.controller,
                              ),
                            );
                          }

                          final attempts =
                              attemptSnapshot.data!.docs;

                          final submitted = attempts.where(
                                (doc) =>
                            doc.data()['status'] ==
                                'submitted',
                          );

                          final submittedList =
                          submitted.toList();

                          if (submittedList.isEmpty) {
                            return _emptyReport();
                          }

                          final percentages =
                          submittedList
                              .map(
                                (doc) =>
                            (doc.data()[
                            'percentage']
                            as num?)
                                ?.toDouble() ??
                                0,
                          )
                              .toList();

                          final average =
                              percentages.reduce(
                                    (a, b) => a + b,
                              ) /
                                  percentages.length;

                          final passed = percentages
                              .where(
                                (score) =>
                            score >= passing,
                          )
                              .length;

                          final passRate =
                              (passed /
                                  percentages.length) *
                                  100;

                          final excellent =
                              percentages
                                  .where(
                                    (score) =>
                                score >= 90,
                              )
                                  .length;

                          final good = percentages
                              .where(
                                (score) =>
                            score >= 70 &&
                                score < 90,
                          )
                              .length;

                          final averageBand =
                              percentages
                                  .where(
                                    (score) =>
                                score >= 50 &&
                                    score < 70,
                              )
                                  .length;

                          final below = percentages
                              .where(
                                (score) => score < 50,
                          )
                              .length;

                          return Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // ==========================================
                              // METRICS
                              // ==========================================
                              Row(
                                children: [
                                  Expanded(
                                    child: _metricCard(
                                      '${average.toStringAsFixed(0)}%',
                                      'Class Average',
                                      Icons.trending_up_rounded,
                                      AppColors.controller,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _metricCard(
                                      '${passRate.toStringAsFixed(0)}%',
                                      'Pass Rate',
                                      Icons
                                          .check_circle_outline_rounded,
                                      AppColors.controller,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // ==========================================
                              // SCORE DISTRIBUTION
                              // ==========================================
                              Container(
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(17),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFE5EAF1,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 12,
                                      offset:
                                      const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .leaderboard_rounded,
                                          color:
                                          AppColors.controller,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Score Distribution',
                                          style: TextStyle(
                                            color:
                                            AppColors.navy,
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '${submittedList.length} submitted attempts',
                                      style: const TextStyle(
                                        color: AppColors
                                            .textSecondary,
                                        fontSize: 9.5,
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    _scoreRow(
                                      '90–100%',
                                      excellent,
                                      percentages.length,
                                      const Color(
                                        0xFFE59A21,
                                      ),
                                    ),

                                    _scoreRow(
                                      '70–89%',
                                      good,
                                      percentages.length,
                                      const Color(
                                        0xFFF0B44D,
                                      ),
                                    ),

                                    _scoreRow(
                                      '50–69%',
                                      averageBand,
                                      percentages.length,
                                      const Color(
                                        0xFFF5C978,
                                      ),
                                    ),

                                    _scoreRow(
                                      'Below 50%',
                                      below,
                                      percentages.length,
                                      const Color(
                                        0xFFD88A18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ==========================================
                              // QUESTION ANALYTICS
                              // ==========================================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(17),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFE5EAF1,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 12,
                                      offset:
                                      const Offset(0, 4),
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
                                          width: 38,
                                          height: 38,
                                          decoration:
                                          BoxDecoration(
                                            color: AppColors
                                                .controller
                                                .withValues(
                                              alpha: 0.10,
                                            ),
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons
                                                .insights_rounded,
                                            color: AppColors
                                                .controller,
                                            size: 20,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        const Expanded(
                                          child: Text(
                                            'Question Analytics',
                                            style: TextStyle(
                                              color:
                                              AppColors.navy,
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight
                                                  .w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Container(
                                      width: double.infinity,
                                      padding:
                                      const EdgeInsets.all(
                                        13,
                                      ),
                                      decoration:
                                      BoxDecoration(
                                        color: AppColors
                                            .controller
                                            .withValues(
                                          alpha: 0.055,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Hardest-question analytics will appear after student attempts store answer-level correctness data.',
                                        style: TextStyle(
                                          color: AppColors
                                              .textSecondary,
                                          fontSize: 10.5,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY REPORT
  // =========================================================

  Widget _emptyReport() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5EAF1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.controller.withValues(
                alpha: 0.09,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 32,
              color: AppColors.controller,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No Submitted Attempts Yet',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Performance statistics will appear here after students submit this exam.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // METRIC CARD
  // =========================================================

  Widget _metricCard(
      String value,
      String label,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5EAF1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.02,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            value,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SCORE ROW
  // =========================================================

  Widget _scoreRow(
      String label,
      int count,
      int total,
      Color color,
      ) {
    final value =
    total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              color: color,
              backgroundColor:
              const Color(0xFFF0F2F5),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// NO OFFICIAL EXAMS
// =========================================================

class _NoOfficialExams extends StatelessWidget {
  const _NoOfficialExams();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.controller.withValues(
                  alpha: 0.09,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: AppColors.controller,
                size: 35,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'No Official Exams',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Official exam reports will appear here when exams become available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}