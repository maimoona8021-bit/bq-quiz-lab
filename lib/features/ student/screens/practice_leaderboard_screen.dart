import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/firestore_service.dart';

class PracticeLeaderboardScreen extends StatelessWidget {
  final String? quizId;

  const PracticeLeaderboardScreen({
    super.key,
    this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    if (quizId == null) {
      return const _LeaderboardQuizSelector();
    }

    return _LeaderboardResults(
      quizId: quizId!,
    );
  }
}

// ==========================================================
// LEADERBOARD QUIZ SELECTOR
// Practice + Official
// ==========================================================

class _LeaderboardQuizSelector extends StatelessWidget {
  const _LeaderboardQuizSelector();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirestoreService();

    if (user == null) {
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Leaderboards',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.studentProfileStream(
          user.uid,
        ),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load profile.',
              ),
            );
          }

          if (!profileSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.student,
              ),
            );
          }

          final batch = profileSnapshot
              .data!
              .data()?['classBatch']
              ?.toString() ??
              '';

          return StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.studentLeaderboardQuizzesStream(
              batch,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Unable to load leaderboards.',
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.student,
                  ),
                );
              }

              // ==================================================
              // BOTH PRACTICE + OFFICIAL
              // Teacher must enable leaderboardVisible
              final quizzes = snapshot.data!.docs.where(
                    (doc) {
                  final data = doc.data();

                  // Teacher did NOT enable leaderboard.
                  // Completely hide this quiz.
                  if (data['leaderboardVisible'] != true) {
                    return false;
                  }

                  final type =
                  data['quizType']
                      ?.toString()
                      .toLowerCase();

                  final status =
                  data['status']
                      ?.toString()
                      .toLowerCase();

                  // Practice leaderboard
                  if (type == 'practice') {
                    return status == 'published' ||
                        status == 'closed';
                  }

                  // Official leaderboard is hidden
                  // until Controller releases results.
                  if (type == 'official') {
                    return status ==
                        'results_released';
                  }

                  return false;
                },
              ).toList();
              if (quizzes.isEmpty) {
                return const _NoLeaderboard();
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  28,
                ),
                children: [
                  const Text(
                    'AVAILABLE LEADERBOARDS',
                    style: TextStyle(
                      color:
                      AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Choose an exam to view its ranking',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...quizzes.map(
                        (doc) {
                      final data = doc.data();

                      final type =
                          data['quizType']
                              ?.toString() ??
                              'practice';

                      final official =
                          type == 'official';

                      final questionCount =
                          List.from(
                            data['questionIds'] ?? [],
                          ).length;

                      return Container(
                        margin:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        decoration:
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFE3E9F1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.025),
                              blurRadius: 12,
                              offset:
                              const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration:
                            BoxDecoration(
                              color: AppColors.student
                                  .withOpacity(.09),
                              borderRadius:
                              BorderRadius.circular(
                                13,
                              ),
                            ),
                            child: Icon(
                              official
                                  ? Icons
                                  .workspace_premium_rounded
                                  : Icons
                                  .emoji_events_rounded,
                              color:
                              AppColors.student,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            data['title']
                                ?.toString() ??
                                'Quiz',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                            const EdgeInsets.only(
                              top: 6,
                            ),
                            child: Row(
                              children: [
                                _QuizTypeChip(
                                  official: official,
                                ),

                                const SizedBox(
                                  width: 7,
                                ),

                                Expanded(
                                  child: Text(
                                    '${data['subject'] ?? 'General'} • '
                                        '$questionCount questions',
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                    style:
                                    const TextStyle(
                                      color: AppColors
                                          .textSecondary,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(
                            Icons
                                .chevron_right_rounded,
                            color: AppColors.navy,
                          ),
                          onTap: () {
                            // Keep existing route
                            // so no navigation breaks.
                            Navigator
                                .pushReplacementNamed(
                              context,
                              AppRoutes
                                  .practiceLeaderboard,
                              arguments: doc.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================================
// ACTUAL LEADERBOARD
// ==========================================================

class _LeaderboardResults extends StatelessWidget {
  final String quizId;

  const _LeaderboardResults({
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    final currentUser =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.quizStream(
          quizId,
        ),
        builder: (context, quizSnapshot) {
          if (quizSnapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load quiz.',
              ),
            );
          }

          if (!quizSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.student,
              ),
            );
          }

          final quiz =
              quizSnapshot.data!.data() ?? {};

          final quizType =
              quiz['quizType']?.toString() ??
                  'practice';

          final isOfficial =
              quizType == 'official';

          final validType =
              quizType == 'practice' ||
                  quizType == 'official';

          final allowed =
              validType &&
                  quiz['leaderboardVisible'] ==
                      true;

          if (!allowed) {
            return const _LeaderboardDisabled();
          }

          final classBatch =
              quiz['classBatch']?.toString() ??
                  '';

          return StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore
                .leaderboardAttemptsStream(
              quizId: quizId,
              classBatch: classBatch,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(
                      20,
                    ),
                    child: Text(
                      'Unable to load leaderboard.\n'
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
                    AppColors.student,
                  ),
                );
              }

              // =================================================
              // OFFICIAL:
              // Only include attempts whose results are released.
              //
              // PRACTICE:
              // All completed attempts are allowed.
              // =================================================

              final allAttempts =
                  snapshot.data!.docs;

              final eligibleAttempts =
              isOfficial
                  ? allAttempts.where(
                    (doc) {
                  return doc.data()[
                  'resultReleased'] ==
                      true;
                },
              ).toList()
                  : allAttempts;

              if (isOfficial &&
                  allAttempts.isNotEmpty &&
                  eligibleAttempts.isEmpty) {
                return const _OfficialLeaderboardHeld();
              }

              // =================================================
              // BEST ATTEMPT PER STUDENT
              // Practice can have multiple attempts.
              // Official normally has one.
              // =================================================

              final Map<
                  String,
                  QueryDocumentSnapshot<
                      Map<String, dynamic>>>
              bestByStudent = {};

              for (final doc
              in eligibleAttempts) {
                final data = doc.data();

                final studentId =
                    data['studentId']
                        ?.toString() ??
                        '';

                if (studentId.isEmpty) {
                  continue;
                }

                final old =
                bestByStudent[studentId];

                if (old == null ||
                    _isBetter(
                      data,
                      old.data(),
                    )) {
                  bestByStudent[
                  studentId] = doc;
                }
              }

              final ranking =
              bestByStudent.values
                  .toList();

              ranking.sort(
                    (a, b) => _compare(
                  a.data(),
                  b.data(),
                ),
              );

              if (ranking.isEmpty) {
                return const _NoAttempts();
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  30,
                ),
                children: [
                  _LeaderboardHeader(
                    title:
                    quiz['title']?.toString() ??
                        'Quiz',
                    subject:
                    quiz['subject']?.toString() ??
                        'General',
                    official: isOfficial,
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // PODIUM
                  // =================================================

                  if (ranking.length >= 3)
                    _TopThree(
                      ranking: ranking,
                    ),

                  if (ranking.length >= 3)
                    const SizedBox(height: 28),

                  // =================================================
                  // FULL RANKING
                  //
                  // If podium exists, begin at #4
                  // exactly like your reference UI.
                  // =================================================

                  if (ranking.length > 3) ...[
                    const Text(
                      'FULL RANKING',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        letterSpacing: .7,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...List.generate(
                      ranking.length - 3,
                          (listIndex) {
                        final index =
                            listIndex + 3;

                        final data =
                        ranking[index].data();

                        final isMe =
                            currentUser?.uid ==
                                data[
                                'studentId'];

                        return _RankingCard(
                          rank: index + 1,
                          data: data,
                          isMe: isMe,
                        );
                      },
                    ),
                  ],

                  // Fewer than 3 students:
                  // use normal ranking cards
                  if (ranking.length < 3) ...[
                    const Text(
                      'RANKING',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        letterSpacing: .7,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...List.generate(
                      ranking.length,
                          (index) {
                        final data =
                        ranking[index].data();

                        final isMe =
                            currentUser?.uid ==
                                data[
                                'studentId'];

                        return _RankingCard(
                          rank: index + 1,
                          data: data,
                          isMe: isMe,
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  static bool _isBetter(
      Map<String, dynamic> newAttempt,
      Map<String, dynamic> oldAttempt,
      ) {
    final newPercentage =
        (newAttempt['percentage'] as num?)
            ?.toDouble() ??
            0;

    final oldPercentage =
        (oldAttempt['percentage'] as num?)
            ?.toDouble() ??
            0;

    if (newPercentage != oldPercentage) {
      return newPercentage >
          oldPercentage;
    }

    final newTime =
        (newAttempt['timeTakenSeconds']
        as num?)
            ?.toInt() ??
            999999;

    final oldTime =
        (oldAttempt['timeTakenSeconds']
        as num?)
            ?.toInt() ??
            999999;

    return newTime < oldTime;
  }

  static int _compare(
      Map<String, dynamic> a,
      Map<String, dynamic> b,
      ) {
    final aPercentage =
        (a['percentage'] as num?)
            ?.toDouble() ??
            0;

    final bPercentage =
        (b['percentage'] as num?)
            ?.toDouble() ??
            0;

    final percentageCompare =
    bPercentage.compareTo(
      aPercentage,
    );

    if (percentageCompare != 0) {
      return percentageCompare;
    }

    final aTime =
        (a['timeTakenSeconds'] as num?)
            ?.toInt() ??
            999999;

    final bTime =
        (b['timeTakenSeconds'] as num?)
            ?.toInt() ??
            999999;

    return aTime.compareTo(bTime);
  }
}

// ==========================================================
// HEADER
// ==========================================================

class _LeaderboardHeader extends StatelessWidget {
  final String title;
  final String subject;
  final bool official;

  const _LeaderboardHeader({
    required this.title,
    required this.subject,
    required this.official,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(
          18,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy
                .withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.student
                  .withOpacity(.15),
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              official
                  ? Icons
                  .workspace_premium_rounded
                  : Icons
                  .emoji_events_rounded,
              color: AppColors.student,
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _QuizTypeChip(
                      official: official,
                      darkBackground: true,
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  title,
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
                  subject,
                  style: const TextStyle(
                    color: Color(
                      0xFFABB7CA,
                    ),
                    fontSize: 10,
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

// ==========================================================
// TOP 3 PODIUM
// ==========================================================

class _TopThree extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> ranking;

  const _TopThree({
    required this.ranking,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _PodiumPerson(
              data: ranking[1].data(),
              rank: 2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PodiumPerson(
              data: ranking[0].data(),
              rank: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PodiumPerson(
              data: ranking[2].data(),
              rank: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPerson extends StatelessWidget {
  final Map<String, dynamic> data;
  final int rank;

  const _PodiumPerson({
    required this.data,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        data['studentName']?.toString() ?? 'Student';

    final trimmed = name.trim();

    final initial =
    trimmed.isNotEmpty
        ? trimmed[0].toUpperCase()
        : 'S';

    Color mainColor;
    Color avatarColor;
    Color podiumColor;
    double avatarRadius;
    double podiumHeight;

    if (rank == 1) {
      mainColor = const Color(0xFFF59E0B);
      avatarColor = const Color(0xFFF59E0B);
      podiumColor = const Color(0xFFFFF4DD);
      avatarRadius = 30;
      podiumHeight = 110;
    } else if (rank == 2) {
      mainColor = const Color(0xFF94A3B8);
      avatarColor = const Color(0xFF94A3B8);
      podiumColor = const Color(0xFFF1F5F9);
      avatarRadius = 26;
      podiumHeight = 82;
    } else {
      mainColor = const Color(0xFFC56A16);
      avatarColor = const Color(0xFFC56A16);
      podiumColor = const Color(0xFFF9EEE5);
      avatarRadius = 26;
      podiumHeight = 62;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: avatarColor,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: rank == 1 ? 18 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border(
              top: BorderSide(
                color: mainColor,
                width: 3,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rank',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data['percentage'] ?? 0}%',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ==========================================================
// FULL RANKING CARD
// ==========================================================

class _RankingCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> data;
  final bool isMe;

  const _RankingCard({
    required this.rank,
    required this.data,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final seconds =
        (data['timeTakenSeconds'] as num?)
            ?.toInt() ??
            0;

    final minutes = seconds ~/ 60;

    final remainingSeconds =
        seconds % 60;

    final name =
        data['studentName']?.toString() ??
            'Student';

    final trimmed = name.trim();

    final initial =
    trimmed.isNotEmpty
        ? trimmed[0].toUpperCase()
        : 'S';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.student
            .withOpacity(.055)
            : Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: isMe
              ? AppColors.student
              .withOpacity(.55)
              : const Color(
            0xFFE2E8F0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.018),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Color(
                  0xFF64748B,
                ),
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          CircleAvatar(
            radius: 23,
            backgroundColor:
            const Color(
              0xFF71849F,
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                if (isMe) ...[
                  const SizedBox(width: 5),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration:
                    BoxDecoration(
                      color: AppColors
                          .student
                          .withOpacity(.10),
                      borderRadius:
                      BorderRadius
                          .circular(
                        6,
                      ),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        color:
                        AppColors.student,
                        fontSize: 7,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '${data['percentage'] ?? 0}%',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '$minutes:${remainingSeconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color:
                  AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// TYPE CHIP
// ==========================================================

class _QuizTypeChip extends StatelessWidget {
  final bool official;
  final bool darkBackground;

  const _QuizTypeChip({
    required this.official,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: darkBackground
            ? AppColors.student
            .withOpacity(.15)
            : AppColors.student
            .withOpacity(.08),
        borderRadius:
        BorderRadius.circular(6),
      ),
      child: Text(
        official
            ? 'OFFICIAL'
            : 'PRACTICE',
        style: const TextStyle(
          color: AppColors.student,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

// ==========================================================
// OFFICIAL RESULT NOT RELEASED
// ==========================================================

class _OfficialLeaderboardHeld
    extends StatelessWidget {
  const _OfficialLeaderboardHeld();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.student
                    .withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                color: AppColors.student,
                size: 33,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Leaderboard Not Available Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'The official exam leaderboard will appear after the results are released.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
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

// ==========================================================
// LEADERBOARD DISABLED
// ==========================================================

class _LeaderboardDisabled
    extends StatelessWidget {
  const _LeaderboardDisabled();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 55,
              color: Color(
                0xFF9AA7B8,
              ),
            ),

            SizedBox(height: 14),

            Text(
              'Leaderboard Disabled',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'The teacher has disabled the leaderboard for this quiz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// NO ATTEMPTS
// ==========================================================

class _NoAttempts extends StatelessWidget {
  const _NoAttempts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No completed attempts yet.',
        style: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ==========================================================
// NO AVAILABLE LEADERBOARD
// ==========================================================

class _NoLeaderboard extends StatelessWidget {
  const _NoLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .emoji_events_outlined,
              size: 58,
              color: Color(
                0xFF9AA7B8,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'No Leaderboards',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Leaderboards will appear here when they are enabled for a Practice or Official exam.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textSecondary,
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