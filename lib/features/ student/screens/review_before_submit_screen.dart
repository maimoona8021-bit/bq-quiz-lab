import 'package:flutter/material.dart';

import '../../../ core/theme/app_colors.dart';

class ReviewBeforeSubmitScreen extends StatelessWidget {
  final int totalQuestions;
  final Set<int> answered;
  final Set<int> flagged;

  const ReviewBeforeSubmitScreen({
    super.key,
    required this.totalQuestions,
    required this.answered,
    required this.flagged,
  });

  @override
  Widget build(BuildContext context) {
    final unansweredCount =
        totalQuestions - answered.length;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Review Your Answers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ==========================================
            // MAIN CONTENT
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  10,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Before you submit',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Review your progress and return to any question you want to check.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==========================================
                    // SUMMARY CARDS
                    // ==========================================
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            value: '${answered.length}',
                            label: 'Answered',
                            icon: Icons
                                .check_circle_outline_rounded,
                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: _Stat(
                            value: '$unansweredCount',
                            label: 'Unanswered',
                            icon: Icons
                                .radio_button_unchecked_rounded,
                            color: AppColors.navy,
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: _Stat(
                            value: '${flagged.length}',
                            label: 'Flagged',
                            icon: Icons.flag_outlined,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Text(
                          'Questions',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          '$totalQuestions total',
                          style: const TextStyle(
                            color:
                            AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // QUESTION GRID CARD
                    // ==========================================
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(
                              0xFFE6EBF2,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.025),
                              blurRadius: 14,
                              offset:
                              const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Legend
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceEvenly,
                              children: const [
                                _Legend(
                                  color: Colors.green,
                                  label: 'Answered',
                                ),
                                _Legend(
                                  color: Colors.orange,
                                  label: 'Flagged',
                                ),
                                _Legend(
                                  color: Color(
                                    0xFFB4BDCA,
                                  ),
                                  label: 'Unanswered',
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Expanded(
                              child: GridView.builder(
                                padding:
                                const EdgeInsets.only(
                                  bottom: 4,
                                ),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  mainAxisSpacing: 13,
                                  crossAxisSpacing: 13,
                                  childAspectRatio: 1,
                                ),
                                itemCount:
                                totalQuestions,
                                itemBuilder:
                                    (context, index) {
                                  final isAnswered =
                                  answered.contains(
                                    index,
                                  );

                                  final isFlagged =
                                  flagged.contains(
                                    index,
                                  );

                                  Color color =
                                  const Color(
                                    0xFFB4BDCA,
                                  );

                                  Color background =
                                  const Color(
                                    0xFFF5F7FA,
                                  );

                                  if (isAnswered) {
                                    color =
                                        Colors.green;
                                    background =
                                        Colors.green
                                            .withOpacity(
                                          .08,
                                        );
                                  }

                                  // Flagged has priority
                                  if (isFlagged) {
                                    color =
                                        Colors.orange;
                                    background =
                                        Colors.orange
                                            .withOpacity(
                                          .09,
                                        );
                                  }

                                  return InkWell(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      50,
                                    ),
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                        index,
                                      );
                                    },
                                    child: Container(
                                      alignment:
                                      Alignment.center,
                                      decoration:
                                      BoxDecoration(
                                        shape:
                                        BoxShape.circle,
                                        color:
                                        background,
                                        border:
                                        Border.all(
                                          color: color,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment:
                                        Alignment.center,
                                        children: [
                                          Text(
                                            '${index + 1}',
                                            style:
                                            TextStyle(
                                              color:
                                              color,
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight
                                                  .w700,
                                            ),
                                          ),

                                          if (isFlagged)
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child:
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration:
                                                const BoxDecoration(
                                                  color:
                                                  Colors.orange,
                                                  shape:
                                                  BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // BOTTOM BUTTON AREA
            // ==========================================
            Container(
              padding: const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          AppColors.navy,
                          side: const BorderSide(
                            color: Color(
                              0xFFD7DFE9,
                            ),
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons
                              .arrow_back_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Return',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child:
                      ElevatedButton.icon(
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.student,
                          foregroundColor:
                          Colors.white,
                          elevation: 1,
                          shadowColor:
                          AppColors.student
                              .withOpacity(.2),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            -1,
                          );
                        },
                        iconAlignment:
                        IconAlignment.end,
                        icon: const Icon(
                          Icons
                              .check_circle_outline_rounded,
                          size: 19,
                        ),
                        label: const Text(
                          'Submit Quiz',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY STAT CARD
// ============================================================

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE6EBF2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LEGEND ITEM
// ============================================================

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}