import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/firestore_service.dart';
import '../widgets/teacher_bottom_nav.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No active teacher session.'),
        ),
      );
    }

    final String teacherId = user.uid;
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: const TeacherBottomNav(
        currentIndex: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream:
              firestoreService.teacherProfileStream(teacherId),
              builder: (context, snapshot) {
                String teacherName =
                user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!
                    : 'Teacher';

                if (snapshot.hasData &&
                    snapshot.data!.exists) {
                  final data = snapshot.data!.data();

                  final firestoreName =
                  data?['name']?.toString().trim();

                  if (firestoreName != null &&
                      firestoreName.isNotEmpty) {
                    teacherName = firestoreName;
                  }
                }

                return _TeacherHeader(
                  teacherName: teacherName,
                );
              },
            ),

            // ==================================================
            // DASHBOARD BODY
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'OVERVIEW',
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _LiveStatCard(
                            stream: firestoreService.teacherQuestionsStream(
                              teacherId,
                            ),
                            icon: Icons.quiz_rounded,
                            label: 'Total Questions',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _LiveStatCard(
                            stream: firestoreService.teacherQuizzesStream(
                              teacherId,
                            ),
                            icon: Icons.library_books_rounded,
                            label: 'Total Quizzes',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _LiveStatCard(
                            stream: firestoreService.teacherQuizzesStream(
                              teacherId,
                            ),
                            icon: Icons.verified_rounded,
                            label: 'Published',
                            filter: (doc) {
                              return doc
                                  .data()['status']
                                  ?.toString()
                                  .toLowerCase() ==
                                  'published';
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _LiveStatCard(
                            stream: firestoreService.teacherAttemptsStream(
                              teacherId,
                            ),
                            icon: Icons.groups_rounded,
                            label: 'Attempts',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      title: 'QUICK ACTIONS',
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryActionButton(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Add Question',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addQuestion,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _SecondaryActionButton(
                            icon: Icons.post_add_rounded,
                            label: 'Create Quiz',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.createQuiz,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle(
                          title: 'RECENT QUIZZES',
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.myQuizzes,
                            );
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: AppColors.teacher,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: firestoreService.teacherQuizzesStream(
                        teacherId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE4E9F0),
                              ),
                            ),
                            child: const Text(
                              'Unable to load recent quizzes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: AppColors.teacher,
                              ),
                            ),
                          );
                        }

                        final quizzes = [
                          ...snapshot.data!.docs,
                        ];

                        quizzes.sort((a, b) {
                          final aTime = a.data()['createdAt'];
                          final bTime = b.data()['createdAt'];

                          if (aTime is Timestamp &&
                              bTime is Timestamp) {
                            return bTime.compareTo(aTime);
                          }

                          return 0;
                        });

                        final recentQuizzes =
                        quizzes.take(3).toList();

                        if (recentQuizzes.isEmpty) {
                          return const _EmptyQuizState();
                        }

                        return Column(
                          children: recentQuizzes.map((doc) {
                            final data = doc.data();

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: _RecentQuizCard(
                                title:
                                data['title']?.toString() ??
                                    'Untitled Quiz',

                                subject:
                                data['subject']?.toString() ??
                                    'General',

                                type:
                                data['quizType']?.toString() ??
                                    'practice',

                                status:
                                data['status']?.toString() ??
                                    'draft',

                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.myQuizzes,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==========================================================
// HEADER
// ==========================================================

class _TeacherHeader extends StatelessWidget {
  final String teacherName;

  const _TeacherHeader({
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF20B7A7),
                  Color(0xFF0B8176),
                ],
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(teacherName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Color(0xFFAAB6CA),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  teacherName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // No notification feature yet.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
              AppColors.teacher.withValues(
                alpha: 0.16,
              ),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: Color(0xFF69D9CC),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Teacher',
                  style: TextStyle(
                    color: Color(0xFF69D9CC),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'T';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}


// ==========================================================
// STAT CARD
// ==========================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE4E9F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color:
              AppColors.teacher.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 17,
              color: AppColors.teacher,
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color:
                  AppColors.textPrimary,
                  fontSize: 21,
                  height: 1,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color:
                  AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveStatCard extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final IconData icon;
  final String label;

  final bool Function(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      )? filter;

  const _LiveStatCard({
    required this.stream,
    required this.icon,
    required this.label,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _StatCard(
            icon: icon,
            value: '—',
            label: label,
          );
        }

        if (!snapshot.hasData) {
          return _StatCard(
            icon: icon,
            value: '...',
            label: label,
          );
        }

        final docs = snapshot.data!.docs;

        final int count = filter == null
            ? docs.length
            : docs.where(filter!).length;

        return _StatCard(
          icon: icon,
          value: '$count',
          label: label,
        );
      },
    );
  }
}
// ==========================================================
// QUICK ACTION BUTTON
// ==========================================================

class _PrimaryActionButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
          AppColors.teacher,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }
}


class _SecondaryActionButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor:
          AppColors.teacher,
          side: const BorderSide(
            color: AppColors.teacher,
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }
}


// ==========================================================
// SECTION TITLE
// ==========================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF65728A),
        fontSize: 10,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}


// ==========================================================
// RECENT QUIZ CARD
// ==========================================================

class _RecentQuizCard
    extends StatelessWidget {
  final String title;
  final String subject;
  final String type;
  final String status;
  final VoidCallback onTap;

  const _RecentQuizCard({
    required this.title,
    required this.subject,
    required this.type,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String normalizedStatus =
    status.toLowerCase();

    Color statusBackground;
    Color statusText;

    switch (normalizedStatus) {
      case 'published':
        statusBackground =
        const Color(0xFFE8F8ED);
        statusText =
        const Color(0xFF21A45A);
        break;

      case 'pending_approval':
        statusBackground =
        const Color(0xFFFFF4DE);
        statusText =
        const Color(0xFFDB8B00);
        break;

      case 'closed':
        statusBackground =
        const Color(0xFFFFECEC);
        statusText =
        const Color(0xFFE54B4B);
        break;

      default:
        statusBackground =
        const Color(0xFFF0F3F8);
        statusText =
        const Color(0xFF68758C);
    }
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4E9F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.teacher
                      .withValues(alpha: 0.09),
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons
                      .assignment_rounded,
                  color: AppColors.teacher,
                  size: 19,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors
                            .textPrimary,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$subject • ${_capitalize(type)}',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  normalizedStatus
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  style: TextStyle(
                    color: statusText,
                    fontSize: 8,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return '';

    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }
}


// ==========================================================
// EMPTY QUIZ STATE
// ==========================================================

class _EmptyQuizState
    extends StatelessWidget {
  const _EmptyQuizState();


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4E9F0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            color: Color(0xFF9CA8B9),
            size: 34,
          ),

          SizedBox(height: 9),

          Text(
            'No quizzes yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 4),

          Text(
            'Create your first quiz to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}