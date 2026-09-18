import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../widgets/teacher_bottom_nav.dart';

class MyQuizzesScreen extends StatefulWidget {
  const MyQuizzesScreen({
    super.key,
  });

  @override
  State<MyQuizzesScreen> createState() =>
      _MyQuizzesScreenState();
}

class _MyQuizzesScreenState
    extends State<MyQuizzesScreen> {
  final FirestoreService _firestore =
  FirestoreService();

  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Teacher not logged in.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,

      bottomNavigationBar:
      const TeacherBottomNav(
        currentIndex: 2,
      ),

      // ==========================================================
      // ADD QUIZ
      // ==========================================================

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        AppColors.teacher,
        foregroundColor:
        Colors.white,
        elevation: 3,
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.createQuiz,
          );
        },
        child: const Icon(
          Icons.add_rounded,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.fromLTRB(
                18,
                17,
                18,
                17,
              ),
              color:
              AppColors.navy,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                    BoxDecoration(
                      color: AppColors
                          .teacher
                          .withValues(
                        alpha: 0.16,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        11,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .quiz_rounded,
                      color:
                      AppColors.teacher,
                      size: 20,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'My Quizzes',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            18,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),

                        SizedBox(
                          height: 2,
                        ),

                        Text(
                          'Manage your practice and official exams',
                          style:
                          TextStyle(
                            color:
                            Color(
                              0xFF9FAAC0,
                            ),
                            fontSize:
                            8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ====================================================
            // FILTERS
            // ====================================================

            _filters(),

            // ====================================================
            // QUIZ LIST
            // ====================================================

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                stream: _firestore
                    .teacherQuizzesStream(
                  user.uid,
                ),
                builder:
                    (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load quizzes.',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        AppColors.teacher,
                      ),
                    );
                  }

                  var docs =
                  [...snapshot.data!.docs];

                  docs = docs.where(
                        (doc) {
                      final data =
                      doc.data();

                      final type =
                          data['quizType']
                              ?.toString()
                              .toLowerCase() ??
                              '';

                      final status =
                          data['status']
                              ?.toString()
                              .toLowerCase() ??
                              '';

                      if (_filter ==
                          'all') {
                        return true;
                      }

                      return type ==
                          _filter ||
                          status ==
                              _filter;
                    },
                  ).toList();

                  // NEWEST FIRST

                  docs.sort(
                        (a, b) {
                      final aTime =
                      a.data()[
                      'createdAt'];

                      final bTime =
                      b.data()[
                      'createdAt'];

                      if (aTime
                      is Timestamp &&
                          bTime
                          is Timestamp) {
                        return bTime
                            .compareTo(
                          aTime,
                        );
                      }

                      return 0;
                    },
                  );

                  if (docs.isEmpty) {
                    return const _EmptyQuizzes();
                  }

                  return ListView.separated(
                    padding:
                    const EdgeInsets.fromLTRB(
                      14,
                      5,
                      14,
                      90,
                    ),
                    itemCount:
                    docs.length,
                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      height: 10,
                    ),
                    itemBuilder:
                        (context, index) {
                      return _quizCard(
                        docs[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // FILTERS
  // ==============================================================

  Widget _filters() {
    const values = [
      'all',
      'practice',
      'official',
      'draft',
      'published',
      'closed',
    ];

    return Container(
      height: 56,
      color:
      AppColors.background,
      child: ListView.separated(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        scrollDirection:
        Axis.horizontal,
        itemCount:
        values.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 7,
        ),
        itemBuilder:
            (context, index) {
          final item =
          values[index];

          final selected =
              _filter == item;

          return ChoiceChip(
            label:
            Text(
              item.toUpperCase(),
            ),
            selected:
            selected,
            selectedColor:
            AppColors.teacher,
            backgroundColor:
            Colors.white,
            side: BorderSide(
              color: selected
                  ? AppColors.teacher
                  : const Color(
                0xFFDDE4EC,
              ),
            ),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            labelStyle:
            TextStyle(
              fontSize: 8,
              fontWeight:
              FontWeight.w700,
              color: selected
                  ? Colors.white
                  : AppColors
                  .textSecondary,
            ),
            onSelected:
                (_) {
              setState(() {
                _filter =
                    item;
              });
            },
          );
        },
      ),
    );
  }

  // ==============================================================
  // QUIZ CARD
  // ==============================================================

  Widget _quizCard(
      QueryDocumentSnapshot<
          Map<String, dynamic>>
      doc,
      ) {
    final data =
    doc.data();

    final String title =
        data['title']
            ?.toString() ??
            'Untitled Quiz';

    final String subject =
        data['subject']
            ?.toString() ??
            'General';

    final String type =
        data['quizType']
            ?.toString()
            .toLowerCase() ??
            'practice';

    final String status =
        data['status']
            ?.toString()
            .toLowerCase() ??
            'draft';

    final int duration =
        (data['durationMinutes']
        as num?)
            ?.toInt() ??
            0;

    final int questions =
        List.from(
          data['questionIds'] ??
              [],
        ).length;

    final bool canPublish =
        type == 'practice' &&
            status == 'draft';

    final bool canClose =
        status == 'published';

    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          15,
        ),
        border:
        Border.all(
          color:
          const Color(
            0xFFE2E8F0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
              alpha: 0.025,
            ),
            blurRadius:
            10,
            offset:
            const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ======================================================
          // TITLE + STATUS + DELETE
          // ======================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // QUIZ ICON

              Container(
                width: 38,
                height: 38,
                decoration:
                BoxDecoration(
                  color: AppColors
                      .teacher
                      .withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  type ==
                      'official'
                      ? Icons
                      .workspace_premium_rounded
                      : Icons
                      .quiz_rounded,
                  size: 19,
                  color:
                  AppColors.teacher,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color:
                        AppColors
                            .textPrimary,
                        fontSize:
                        12,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      '$subject  •  ${type.toUpperCase()}',
                      style:
                      const TextStyle(
                        color:
                        AppColors
                            .textSecondary,
                        fontSize:
                        8,
                        fontWeight:
                        FontWeight
                            .w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  _statusBadge(
                    status,
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // DELETE

                  InkWell(
                    onTap: () {
                      _deleteQuiz(
                        doc.id,
                        title,
                      );
                    },
                    borderRadius:
                    BorderRadius.circular(
                      8,
                    ),
                    child: Container(
                      width: 29,
                      height: 29,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFFFEEEE,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons
                            .delete_outline_rounded,
                        color:
                        Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          // ======================================================
          // QUIZ INFORMATION
          // ======================================================

          Row(
            children: [
              _infoChip(
                icon:
                Icons
                    .help_outline_rounded,
                text:
                '$questions Questions',
              ),

              const SizedBox(
                width: 8,
              ),

              _infoChip(
                icon:
                Icons
                    .schedule_rounded,
                text:
                '$duration min',
              ),

              const SizedBox(
                width: 8,
              ),

              _infoChip(
                icon:
                type ==
                    'official'
                    ? Icons
                    .verified_rounded
                    : Icons
                    .school_rounded,
                text: type ==
                    'official'
                    ? 'Official'
                    : 'Practice',
              ),
            ],
          ),

          // ======================================================
          // WAITING FOR CONTROLLER
          // ======================================================

          if (type ==
              'official' &&
              status ==
                  'pending_approval') ...[
            const SizedBox(
              height: 11,
            ),

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFFFF6E5,
                ),
                borderRadius:
                BorderRadius.circular(
                  9,
                ),
              ),
              child:
              const Row(
                children: [
                  Icon(
                    Icons
                        .hourglass_top_rounded,
                    color:
                    Colors.orange,
                    size: 15,
                  ),

                  SizedBox(
                    width: 6,
                  ),

                  Expanded(
                    child: Text(
                      'Waiting for Controller approval',
                      style:
                      TextStyle(
                        color:
                        Colors.orange,
                        fontSize:
                        8,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(
            height: 13,
          ),

          // ======================================================
          // ACTION BUTTONS
          // ======================================================

          Row(
            children: [
              // ATTEMPTS - ALWAYS TEAL OUTLINE

              Expanded(
                child:
                OutlinedButton.icon(
                  style:
                  OutlinedButton
                      .styleFrom(
                    foregroundColor:
                    AppColors.teacher,
                    side:
                    const BorderSide(
                      color:
                      AppColors.teacher,
                    ),
                    minimumSize:
                    const Size(
                      0,
                      42,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes
                          .teacherAttempts,
                      arguments: {
                        'quizId':
                        doc.id,
                        'quizTitle':
                        title,
                      },
                    );
                  },
                  icon:
                  const Icon(
                    Icons
                        .groups_rounded,
                    size: 16,
                  ),
                  label:
                  const Text(
                    'Attempts',
                    style:
                    TextStyle(
                      fontSize: 9,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ),

              // PUBLISH

              if (canPublish) ...[
                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                  ElevatedButton.icon(
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      AppColors.teacher,
                      foregroundColor:
                      Colors.white,
                      minimumSize:
                      const Size(
                        0,
                        42,
                      ),
                      elevation:
                      0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    onPressed:
                        () async {
                      try {
                        final pushSent =
                        await _firestore
                            .publishPracticeQuiz(
                          doc.id,
                        );
                        if (!mounted) {
                          return;
                        }


                        ScaffoldMessenger
                            .of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              pushSent
                                  ? 'Practice quiz published. Students notified.'
                                  : 'Quiz published, but phone notification was not sent.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger
                            .of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content:
                            Text(
                              'Unable to publish quiz: $e',
                            ),
                          ),
                        );
                      }
                    },
                    icon:
                    const Icon(
                      Icons
                          .publish_rounded,
                      size: 16,
                    ),
                    label:
                    const Text(
                      'Publish',
                      style:
                      TextStyle(
                        fontSize:
                        9,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ),
              ],

              // CLOSE

              if (canClose) ...[
                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                  OutlinedButton.icon(
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      Colors.red,
                      side:
                      const BorderSide(
                        color:
                        Colors.red,
                      ),
                      minimumSize:
                      const Size(
                        0,
                        42,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    onPressed:
                        () =>
                        _closeQuiz(
                          doc.id,
                        ),
                    icon:
                    const Icon(
                      Icons
                          .lock_outline_rounded,
                      size: 15,
                    ),
                    label:
                    const Text(
                      'Close',
                      style:
                      TextStyle(
                        fontSize:
                        9,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INFO CHIP
  // ==============================================================

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF5F7FA,
        ),
        borderRadius:
        BorderRadius.circular(
          8,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color:
            AppColors
                .textSecondary,
          ),

          const SizedBox(
            width: 4,
          ),

          Text(
            text,
            style:
            const TextStyle(
              color:
              AppColors
                  .textSecondary,
              fontSize: 7,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // STATUS BADGE
  // ==============================================================

  Widget _statusBadge(
      String status,
      ) {
    Color color;
    Color background;

    switch (status) {
      case 'published':
        color =
        const Color(
          0xFF159A61,
        );
        background =
        const Color(
          0xFFE8F8F0,
        );
        break;

      case 'closed':
        color =
        const Color(
          0xFFE04D5C,
        );
        background =
        const Color(
          0xFFFFECEF,
        );
        break;

      case 'pending_approval':
        color =
        const Color(
          0xFFE99A17,
        );
        background =
        const Color(
          0xFFFFF5DF,
        );
        break;

      case 'results_released':
        color =
        const Color(
          0xFF4569D4,
        );
        background =
        const Color(
          0xFFEDF2FF,
        );
        break;

      case 'locked':
        color =
        const Color(
          0xFF7558D8,
        );
        background =
        const Color(
          0xFFF2EFFF,
        );
        break;

      default:
        color =
        const Color(
          0xFF718096,
        );
        background =
        const Color(
          0xFFF0F3F6,
        );
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status
            .replaceAll(
          '_',
          ' ',
        )
            .toUpperCase(),
        style:
        TextStyle(
          color:
          color,
          fontSize:
          7,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // ==============================================================
  // CLOSE QUIZ
  // ==============================================================

  Future<void> _closeQuiz(
      String quizId,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) =>
          AlertDialog(
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            title:
            const Text(
              'Close Quiz?',
            ),
            content:
            const Text(
              'Students will no longer be able to start this quiz.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child:
                const Text(
                  'Cancel',
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child:
                const Text(
                  'Close Quiz',
                  style:
                  TextStyle(
                    color:
                    Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );

    if (result != true) {
      return;
    }

    try {
      await _firestore
          .closeQuiz(
        quizId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
          Text(
            'Quiz closed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            'Unable to close quiz: $e',
          ),
        ),
      );
    }
  }

  // ==============================================================
  // DELETE QUIZ
  // ==============================================================

  Future<void> _deleteQuiz(
      String quizId,
      String title,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) =>
          AlertDialog(
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),

            title:
            const Row(
              children: [
                Icon(
                  Icons
                      .delete_outline_rounded,
                  color:
                  Colors.red,
                ),

                SizedBox(
                  width: 8,
                ),

                Text(
                  'Delete Quiz?',
                ),
              ],
            ),

            content:
            Text(
              'Delete "$title" permanently?\n\n'
                  'This removes the quiz from Firestore and cannot be undone.',
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child:
                const Text(
                  'Cancel',
                ),
              ),

              ElevatedButton(
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.red,
                  foregroundColor:
                  Colors.white,
                  elevation:
                  0,
                ),
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child:
                const Text(
                  'Delete',
                ),
              ),
            ],
          ),
    );

    if (result != true) {
      return;
    }

    try {
      await _firestore
          .deleteQuiz(
        quizId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
          Text(
            'Quiz permanently deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
      e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            message,
          ),
        ),
      );
    }
  }
}


// ================================================================
// EMPTY STATE
// ================================================================

class _EmptyQuizzes extends StatelessWidget {
  const _EmptyQuizzes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration:
              BoxDecoration(
                color: AppColors
                    .teacher
                    .withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
              child:
              const Icon(
                Icons
                    .quiz_outlined,
                color:
                AppColors.teacher,
                size: 28,
              ),
            ),

            const SizedBox(
              height: 13,
            ),

            const Text(
              'No quizzes found',
              style:
              TextStyle(
                color:
                AppColors
                    .textPrimary,
                fontSize: 13,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            const Text(
              'Create a new quiz to get started.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                AppColors
                    .textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}