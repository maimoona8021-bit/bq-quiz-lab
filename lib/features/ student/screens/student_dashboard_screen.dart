import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ widgets/student_bottom_nav.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    final FirestoreService firestore =
    FirestoreService();

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No student session.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFFF6F8FC),

      bottomNavigationBar:
      const StudentBottomNav(
        currentIndex: 0,
      ),

      body: SafeArea(
        child: StreamBuilder<
            DocumentSnapshot<
                Map<String, dynamic>>>(
          stream: firestore
              .studentProfileStream(
            user.uid,
          ),
          builder:
              (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return const Center(
                child: Text(
                  'Unable to load profile.',
                ),
              );
            }

            if (!profileSnapshot.hasData) {
              return const Center(
                child:
                CircularProgressIndicator(
                  color:
                  AppColors.student,
                ),
              );
            }

            final profile =
                profileSnapshot
                    .data!
                    .data() ??
                    {};

            final String name =
                profile['name']
                    ?.toString() ??
                    'Student';

            final String batch =
                profile['classBatch']
                    ?.toString() ??
                    '';

            return Column(
              children: [
                // ================================================
                // HEADER
                // ================================================

                StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream: firestore
                      .studentNotificationsStream(
                    batch,
                  ),
                  builder:
                      (context, snapshot) {
                    int unread = 0;

                    if (snapshot.hasData) {
                      unread = snapshot
                          .data!.docs
                          .where(
                            (doc) {
                          final data =
                          doc.data();

                          final readBy =
                          List<String>.from(
                            data['readBy'] ??
                                [],
                          );

                          return data[
                          'audienceRole'] ==
                              'student' &&
                              !readBy.contains(
                                user.uid,
                              );
                        },
                      ).length;
                    }

                    return _StudentHeader(
                      name: name,
                      unreadCount:
                      unread,
                    );
                  },
                ),

                // ================================================
                // DASHBOARD
                // ================================================

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<
                          Map<String, dynamic>>>(
                    stream: firestore
                        .studentAttemptsStream(
                      user.uid,
                    ),
                    builder:
                        (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                            const EdgeInsets.all(
                              20,
                            ),
                            child: Text(
                              'Unable to load dashboard.\n'
                                  '${snapshot.error}',
                              textAlign:
                              TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                          CircularProgressIndicator(
                            color:
                            AppColors
                                .student,
                          ),
                        );
                      }

                      return _DashboardBody(
                        attempts:
                        snapshot.data!.docs,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


// ================================================================
// HEADER
// ================================================================

class _StudentHeader extends StatelessWidget {
  final String name;
  final int unreadCount;

  const _StudentHeader({
    required this.name,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final String initial =
    name.trim().isEmpty
        ? 'S'
        : name
        .trim()[0]
        .toUpperCase();

    return Container(
      color: AppColors.navy,
      padding:
      const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        14,
      ),
      child: Row(
        children: [
          // PROFILE INITIAL

          Container(
            width: 42,
            height: 42,
            alignment:
            Alignment.center,
            decoration:
            BoxDecoration(
              color:
              AppColors.student,
              shape:
              BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black
                      .withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 8,
                  offset:
                  const Offset(
                    0,
                    3,
                  ),
                ),
              ],
            ),
            child: Text(
              initial,
              style:
              const TextStyle(
                color:
                Colors.white,
                fontSize: 14,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          // STUDENT NAME

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good morning',
                  style:
                  TextStyle(
                    color:
                    Color(0xFFAAB6CB),
                    fontSize: 9,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                const Text(
                  'Keep learning, keep growing!',
                  style:
                  TextStyle(
                    color:
                    Color(0xFF8090AA),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),

          // NOTIFICATIONS

          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes
                    .studentNotifications,
              );
            },
            borderRadius:
            BorderRadius.circular(
              12,
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFF182641,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Stack(
                alignment:
                Alignment.center,
                children: [
                  const Icon(
                    Icons
                        .notifications_none_rounded,
                    color:
                    Colors.white,
                    size: 20,
                  ),

                  if (unreadCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration:
                        const BoxDecoration(
                          color:
                          Color(
                            0xFFFFA000,
                          ),
                          shape:
                          BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// DASHBOARD BODY
// ================================================================

class _DashboardBody extends StatelessWidget {
  final List<
      QueryDocumentSnapshot<
          Map<String, dynamic>>>
  attempts;

  const _DashboardBody({
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // SUBMITTED ATTEMPTS
    // ============================================================

    final submitted =
    attempts.where(
          (doc) =>
      doc.data()['status'] ==
          'submitted',
    ).toList();

    submitted.sort(
          (a, b) {
        final aTime =
        a.data()['submittedAt'];

        final bTime =
        b.data()['submittedAt'];

        if (aTime is Timestamp &&
            bTime is Timestamp) {
          return bTime.compareTo(
            aTime,
          );
        }

        return 0;
      },
    );

    // ============================================================
    // RESULTS STUDENT IS ALLOWED TO SEE
    // ============================================================

    final visibleResults =
    submitted.where(
          (doc) {
        final data =
        doc.data();

        final String type =
            data['quizType']
                ?.toString()
                .toLowerCase() ??
                'practice';

        if (type == 'practice') {
          return true;
        }

        return data[
        'resultReleased'] ==
            true;
      },
    ).toList();

    // ============================================================
    // LAST SCORE
    // ============================================================

    final int lastScore =
    visibleResults.isEmpty
        ? 0
        : (visibleResults.first
        .data()[
    'percentage']
    as num?)
        ?.round() ??
        0;

    // ============================================================
    // AVERAGE
    // ============================================================

    double average = 0;

    if (visibleResults.isNotEmpty) {
      final double total =
      visibleResults.fold<
          double>(
        0,
            (sum, doc) {
          return sum +
              ((doc.data()[
              'percentage']
              as num?)
                  ?.toDouble() ??
                  0);
        },
      );

      average =
          total /
              visibleResults.length;
    }

    // ============================================================
    // STREAK
    // ============================================================

    final practiceAttempts =
    submitted.where(
          (doc) =>
      doc.data()['quizType'] ==
          'practice',
    );

    final int streak =
        practiceAttempts.length;

    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        28,
      ),
      children: [
        // ========================================================
        // PROGRESS
        // ========================================================

        const _SectionHeading(
          title: 'MY PROGRESS',
        ),

        const SizedBox(
          height: 11,
        ),

        Row(
          children: [
            Expanded(
              child:
              _ProgressCard(
                icon:
                Icons
                    .emoji_events_rounded,
                value:
                '$lastScore%',
                label:
                'Last Score',
                accent:
                const Color(
                  0xFF20A86B,
                ),
                background:
                const Color(
                  0xFFEDF9F3,
                ),
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child:
              _ProgressCard(
                icon:
                Icons
                    .local_fire_department_rounded,
                value:
                '$streak days',
                label:
                'Streak',
                accent:
                const Color(
                  0xFFF58220,
                ),
                background:
                const Color(
                  0xFFFFF4E8,
                ),
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child:
              _ProgressCard(
                icon:
                Icons
                    .bar_chart_rounded,
                value:
                '${average.round()}%',
                label:
                'Average',
                accent:
                AppColors.student,
                background:
                const Color(
                  0xFFEDF3FF,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 23,
        ),

        // ========================================================
        // QUICK ACCESS
        // ========================================================

        const _SectionHeading(
          title: 'QUICK ACCESS',
        ),

        const SizedBox(
          height: 11,
        ),

        Row(
          children: [
            Expanded(
              child:
              _QuickAccessCard(
                icon:
                Icons
                    .leaderboard_rounded,
                title:
                'Leaderboard',
                subtitle:
                'See your rank',
                accent:
                const Color(
                  0xFFE5A11C,
                ),
                background:
                const Color(
                  0xFFFFF8E8,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes
                        .practiceLeaderboard,
                  );
                },
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
              _QuickAccessCard(
                icon:
                Icons
                    .assignment_outlined,
                title:
                'Weak Topics',
                subtitle:
                'Focus & improve',
                accent:
                const Color(
                  0xFF7558D8,
                ),
                background:
                const Color(
                  0xFFF3F0FF,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes
                        .weakTopics,
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 24,
        ),

        // ========================================================
        // SUBJECTS
        // ========================================================

        Row(
          children: [
            const Expanded(
              child:
              _SectionHeading(
                title: 'SUBJECTS',
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes
                      .studentExams,
                );
              },
              child:
              const Row(
                children: [
                  Text(
                    'See all',
                    style:
                    TextStyle(
                      color:
                      AppColors
                          .student,
                      fontSize: 9,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),

                  SizedBox(
                    width: 2,
                  ),

                  Icon(
                    Icons
                        .chevron_right_rounded,
                    color:
                    AppColors
                        .student,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 11,
        ),

        const _SubjectGrid(),

        const SizedBox(
          height: 24,
        ),

        // ========================================================
        // RECENT RESULTS
        // ========================================================

        Row(
          children: [
            const Expanded(
              child:
              _SectionHeading(
                title:
                'RECENT RESULTS',
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes
                      .attemptHistory,
                );
              },
              child:
              const Row(
                children: [
                  Text(
                    'See all',
                    style:
                    TextStyle(
                      color:
                      AppColors
                          .student,
                      fontSize: 9,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),

                  SizedBox(
                    width: 2,
                  ),

                  Icon(
                    Icons
                        .chevron_right_rounded,
                    color:
                    AppColors
                        .student,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 11,
        ),

        if (submitted.isEmpty)
          const _EmptyRecent()
        else
          ...submitted
              .take(3)
              .map(
                (doc) =>
                _RecentResultCard(
                  data:
                  doc.data(),
                ),
          ),
      ],
    );
  }
}


// ================================================================
// SECTION HEADING
// ================================================================

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
      const TextStyle(
        color:
        AppColors.textSecondary,
        fontSize: 10,
        fontWeight:
        FontWeight.w800,
        letterSpacing: 0.7,
      ),
    );
  }
}


// ================================================================
// PROGRESS CARD
// ================================================================

class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color background;

  const _ProgressCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding:
      const EdgeInsets.all(
        11,
      ),
      decoration:
      BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color:
          accent.withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
            BoxDecoration(
              color:
              Colors.white,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color:
              accent,
              size: 19,
            ),
          ),

          const Spacer(),

          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            TextStyle(
              color:
              accent,
              fontSize: 14,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,
            style:
            const TextStyle(
              color:
              AppColors
                  .textSecondary,
              fontSize: 8,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// QUICK ACCESS
// ================================================================

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color background;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
      onTap,
      borderRadius:
      BorderRadius.circular(
        15,
      ),
      child: Container(
        height: 78,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),
        decoration:
        BoxDecoration(
          color:
          background,
          borderRadius:
          BorderRadius.circular(
            15,
          ),
          border:
          Border.all(
            color:
            accent.withValues(
              alpha: 0.10,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration:
              BoxDecoration(
                color:
                Colors.white,
                borderRadius:
                BorderRadius.circular(
                  11,
                ),
              ),
              child: Icon(
                icon,
                color:
                accent,
                size: 19,
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color:
                      AppColors
                          .textPrimary,
                      fontSize: 9,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color:
                      AppColors
                          .textSecondary,
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              color:
              Color(
                0xFF98A5B7,
              ),
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}


// ================================================================
// SUBJECT GRID
// ================================================================

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid();

  static const List<_SubjectData>
  subjects = [
    _SubjectData(
      name:
      'Flutter',
      icon:
      Icons.phone_android_rounded,
      accent:
      Color(
        0xFF2F6BF3,
      ),
      background:
      Color(
        0xFFEDF3FF,
      ),
    ),

    _SubjectData(
      name:
      'Web Dev',
      icon:
      Icons.code_rounded,
      accent:
      Color(
        0xFF7558D8,
      ),
      background:
      Color(
        0xFFF3F0FF,
      ),
    ),

    _SubjectData(
      name:
      'Cybersecurity',
      icon:
      Icons.shield_rounded,
      accent:
      Color(
        0xFF16A67A,
      ),
      background:
      Color(
        0xFFEBF9F4,
      ),
    ),

    _SubjectData(
      name:
      'English',
      icon:
      Icons.menu_book_rounded,
      accent:
      Color(
        0xFF5066C8,
      ),
      background:
      Color(
        0xFFF0F2FF,
      ),
    ),

    _SubjectData(
      name:
      'Islamiat',
      icon:
      Icons.auto_stories_rounded,
      accent:
      Color(
        0xFF159A8C,
      ),
      background:
      Color(
        0xFFECF8F6,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap:
      true,

      physics:
      const NeverScrollableScrollPhysics(),

      itemCount:
      6,

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
        3,
        crossAxisSpacing:
        9,
        mainAxisSpacing:
        9,
        childAspectRatio:
        1.20,
      ),

      itemBuilder:
          (context, index) {
        // ========================================================
        // SIXTH CARD = ALL SUBJECTS
        // ========================================================

        if (index == 5) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes
                    .studentExams,
              );
            },

            borderRadius:
            BorderRadius.circular(
              14,
            ),

            child: Container(
              padding:
              const EdgeInsets.all(
                10,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF1F4F8,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 33,
                    height: 33,
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .grid_view_rounded,
                      color:
                      AppColors.student,
                      size:
                      18,
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'All Subjects',
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    TextStyle(
                      color:
                      AppColors
                          .textPrimary,
                      fontSize:
                      8,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final subject =
        subjects[index];

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes
                  .studentExams,
              arguments: {
                'subject':
                subject.name,
              },
            );
          },

          borderRadius:
          BorderRadius.circular(
            14,
          ),

          child: Container(
            padding:
            const EdgeInsets.all(
              10,
            ),

            decoration:
            BoxDecoration(
              color:
              subject.background,
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 33,
                  height: 33,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    subject.icon,
                    color:
                    subject.accent,
                    size:
                    18,
                  ),
                ),

                const Spacer(),

                Text(
                  subject.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .textPrimary,
                    fontSize:
                    8,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _SubjectData {
  final String name;
  final IconData icon;
  final Color accent;
  final Color background;

  const _SubjectData({
    required this.name,
    required this.icon,
    required this.accent,
    required this.background,
  });
}


// ================================================================
// RECENT RESULT
// ================================================================

class _RecentResultCard
    extends StatelessWidget {
  final Map<String, dynamic>
  data;

  const _RecentResultCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final String quizType =
        data['quizType']
            ?.toString()
            .toLowerCase() ??
            'practice';

    final bool resultReleased =
        data['resultReleased'] ==
            true;

    final bool hiddenOfficial =
        quizType ==
            'official' &&
            !resultReleased;

    final int percentage =
        (data['percentage']
        as num?)
            ?.round() ??
            0;

    final bool passed =
        percentage >= 60;

    final Color statusColor =
    hiddenOfficial
        ? const Color(
      0xFFE39A17,
    )
        : passed
        ? const Color(
      0xFF19A66A,
    )
        : const Color(
      0xFFE74C5D,
    );

    final Color statusBackground =
    hiddenOfficial
        ? const Color(
      0xFFFFF4DE,
    )
        : passed
        ? const Color(
      0xFFE9F8F0,
    )
        : const Color(
      0xFFFFECEF,
    );

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 9,
      ),

      padding:
      const EdgeInsets.all(
        11,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          14,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFE6EBF2,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
              alpha: 0.025,
            ),
            blurRadius: 10,
            offset:
            const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            alignment:
            Alignment.center,

            decoration:
            BoxDecoration(
              color:
              statusBackground,

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Text(
              hiddenOfficial
                  ? 'HELD'
                  : '$percentage%',

              style:
              TextStyle(
                color:
                statusColor,

                fontSize:
                hiddenOfficial
                    ? 7
                    : 10,

                fontWeight:
                FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  data['quizTitle']
                      ?.toString() ??
                      'Quiz',

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .textPrimary,

                    fontSize:
                    9,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  quizType ==
                      'practice'
                      ? 'Practice Quiz'
                      : 'Official Exam',

                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .textSecondary,

                    fontSize:
                    7,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 8,
              vertical: 5,
            ),

            decoration:
            BoxDecoration(
              color:
              statusBackground,

              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),

            child: Text(
              hiddenOfficial
                  ? 'HELD'
                  : passed
                  ? 'PASSED'
                  : 'FAILED',

              style:
              TextStyle(
                color:
                statusColor,

                fontSize:
                6,

                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// EMPTY RECENT RESULTS
// ================================================================

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,

      alignment:
      Alignment.center,

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          14,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFE6EBF2,
          ),
        ),
      ),

      child:
      const Text(
        'No results yet.',

        style:
        TextStyle(
          color:
          AppColors
              .textSecondary,

          fontSize:
          9,
        ),
      ),
    );
  }
}