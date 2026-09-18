import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ widgets/student_bottom_nav.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/firestore_service.dart';

class AttemptHistoryScreen
    extends StatefulWidget {
  const AttemptHistoryScreen({
    super.key,
  });

  @override
  State<AttemptHistoryScreen>
  createState() =>
      _AttemptHistoryScreenState();
}

class _AttemptHistoryScreenState
    extends State<AttemptHistoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    final firestore =
    FirestoreService();

    if (user == null) {
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,

      bottomNavigationBar:
      const StudentBottomNav(
        currentIndex: 2,
      ),

      appBar: AppBar(
        backgroundColor:
        AppColors.navy,
        foregroundColor:
        Colors.white,
        title:
        const Text(
          'Attempt History',
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: firestore
            .studentAttemptsStream(
          user.uid,
        ),
        builder:
            (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          var docs =
          [...snapshot.data!.docs];

          docs = docs.where(
                (doc) {
              final data =
              doc.data();

              final String status =
                  data['status']
                      ?.toString() ??
                      '';

              final bool reopened =
                  data['reopened'] ==
                      true;

              // Show:
              // 1. Normal submitted attempts
              // 2. Reopened attempts waiting to resume
              // 3. Reopened attempts already started again
              final bool shouldShow =
                  status == 'submitted' ||
                      status == 'reopened' ||
                      (
                          status ==
                              'in_progress' &&
                              reopened
                      );

              if (!shouldShow) {
                return false;
              }

              if (_filter == 'all') {
                return true;
              }

              return data['quizType'] ==
                  _filter;
            },
          ).toList();

          docs.sort(
                (a, b) {
              final aData =
              a.data();

              final bData =
              b.data();

              final aTime =
                  aData['reopenedAt'] ??
                      aData['submittedAt'] ??
                      aData['updatedAt'];

              final bTime =
                  bData['reopenedAt'] ??
                      bData['submittedAt'] ??
                      bData['updatedAt'];

              if (aTime is Timestamp &&
                  bTime is Timestamp) {
                return bTime.compareTo(
                  aTime,
                );
              }

              return 0;
            },
          );

          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets
                    .all(12),
                child: Row(
                  children: [
                    _chip('all'),
                    _chip(
                      'practice',
                    ),
                    _chip(
                      'official',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: docs.isEmpty
                    ? const Center(
                  child: Text(
                    'No attempts yet.',
                  ),
                )
                    : ListView.separated(
                  padding:
                  const EdgeInsets
                      .all(
                    12,
                  ),
                  itemCount:
                  docs.length,
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                    height: 8,
                  ),
                  itemBuilder:
                      (context,
                      index) {
                        final doc = docs[index];

                        final data = doc.data();

// ======================================================
// HIDE OFFICIAL RESULT UNTIL CONTROLLER RELEASES IT
// ======================================================
                        final String status =
                            data['status']
                                ?.toString() ??
                                '';

                        final bool reopened =
                            data['reopened'] ==
                                true;

                        final bool canResume =
                            reopened &&
                                (
                                    status ==
                                        'reopened' ||
                                        status ==
                                            'in_progress'
                                );

                        final String reopenReason =
                            data['reopenReason']
                                ?.toString() ??
                                '';

                        final String quizType =
                            data['quizType']
                                ?.toString()
                                .toLowerCase() ??
                                'practice';

                        final bool resultReleased =
                            data['resultReleased'] == true;

                        final bool hiddenOfficial =
                            quizType == 'official' &&
                                !resultReleased &&
                                !canResume;

                        final int percentage =
                            (data['percentage'] as num?)
                                ?.round() ??
                                0;

                        return InkWell(
                          onTap: () {
                            if (canResume) {
                              _resumeReopenedAttempt(
                                context,
                                firestore,
                                doc.id,
                                data,
                              );

                              return;
                            }

                            _open(
                              context,
                              firestore,
                              doc.id,
                              data,
                            );
                          },
                      child:
                      Container(
                        padding:
                        const EdgeInsets
                            .all(
                          12,
                        ),
                        decoration:
                        BoxDecoration(
                          color: Colors
                              .white,
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                              canResume
                                  ? const Color(
                                0xFFEDF3FF,
                              )
                                  : hiddenOfficial
                                  ? const Color(
                                0xFFFFF3DD,
                              )
                                  : percentage >= 60
                                  ? const Color(
                                0xFFE9F8EF,
                              )
                                  : const Color(
                                0xFFFFEAEA,
                              ),

                              child: Text(
                                canResume
                                    ? 'REOPEN'
                                    : hiddenOfficial
                                    ? 'HELD'
                                    : '$percentage%',

                                style: TextStyle(
                                  fontSize:
                                  canResume
                                      ? 6
                                      : 8,

                                  color:
                                  canResume
                                      ? AppColors.student
                                      : hiddenOfficial
                                      ? Colors.orange
                                      : percentage >= 60
                                      ? Colors.green
                                      : Colors.red,

                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['quizTitle']?.toString() ??
                                        'Quiz',
                                    style:
                                    const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    data['quizType']?.toString().toUpperCase() ??
                                        '',
                                    style:
                                    const TextStyle(
                                      fontSize: 7,
                                      color: AppColors.textSecondary,
                                    ),

                                  ),
                                  if (canResume) ...[
                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      reopenReason.isEmpty
                                          ? 'Controller reopened this exam.'
                                          : 'Reason: $reopenReason',

                                      maxLines: 2,

                                      overflow:
                                      TextOverflow.ellipsis,

                                      style:
                                      const TextStyle(
                                        fontSize: 7,
                                        color:
                                        AppColors.student,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            canResume
                                ? SizedBox(
                              height: 32,
                              child:
                              ElevatedButton(
                                onPressed: () {
                                  _resumeReopenedAttempt(
                                    context,
                                    firestore,
                                    doc.id,
                                    data,
                                  );
                                },

                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  AppColors.student,

                                  foregroundColor:
                                  Colors.white,

                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 10,
                                  ),

                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      9,
                                    ),
                                  ),
                                ),

                                child:
                                const Text(
                                  'Resume',
                                  style:
                                  TextStyle(
                                    fontSize: 8,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                                : const Icon(
                              Icons
                                  .chevron_right_rounded,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String value) {
    return Padding(
      padding:
      const EdgeInsets.only(
        right: 6,
      ),
      child: ChoiceChip(
        selected:
        _filter == value,
        selectedColor:
        AppColors.student,
        label: Text(
          value.toUpperCase(),
        ),
        labelStyle:
        TextStyle(
          fontSize: 8,
          color:
          _filter == value
              ? Colors.white
              : AppColors
              .textPrimary,
        ),
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }
  Future<void> _resumeReopenedAttempt(
      BuildContext context,
      FirestoreService firestore,
      String attemptId,
      Map<String, dynamic> data,
      ) async {
    final String quizId =
        data['quizId']
            ?.toString() ??
            '';

    if (quizId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz information is missing.',
          ),
        ),
      );

      return;
    }

    try {
      final String status =
          data['status']
              ?.toString() ??
              '';

      // Only change reopened -> in_progress once.
      // If they previously resumed and closed the app,
      // simply reopen the player.
      if (status == 'reopened') {
        await firestore
            .startReopenedAttempt(
          attemptId:
          attemptId,
        );
      }

      if (!context.mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.quizPlayer,
        arguments: {
          'quizId':
          quizId,

          'attemptId':
          attemptId,
        },
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not resume exam: $e',
          ),
        ),
      );
    }
  }



  Future<void> _open(
      BuildContext context,
      FirestoreService firestore,
      String attemptId,
      Map<String, dynamic> data,
      ) async {
    final quizId =
    data['quizId'].toString();

    if (data['quizType'] ==
        'official') {
      final quiz =
      await firestore.getQuiz(
        quizId,
      );

      final released =
          quiz.data()?['status'] ==
              'results_released';

      if (!context.mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        released
            ? AppRoutes.result
            : AppRoutes
            .officialResultWaiting,
        arguments: {
          'attemptId':
          attemptId,
          'quizId':
          quizId,
        },
      );

      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: {
        'attemptId':
        attemptId,
        'quizId':
        quizId,
      },
    );
  }
}