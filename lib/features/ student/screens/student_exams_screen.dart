import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ widgets/student_bottom_nav.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/firestore_service.dart';

class StudentExamsScreen
    extends StatefulWidget {
  final String? initialSubject;

  const StudentExamsScreen({
    super.key,
    this.initialSubject,
  });

  @override
  State<StudentExamsScreen>
  createState() =>
      _StudentExamsScreenState();
}

class _StudentExamsScreenState
    extends State<StudentExamsScreen> {
  final FirestoreService _firestore =
  FirestoreService();

  String? _subject;

  @override
  void initState() {
    super.initState();
    _subject =
        widget.initialSubject;
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,

      bottomNavigationBar:
      const StudentBottomNav(
        currentIndex: 1,
      ),

      appBar: AppBar(
        backgroundColor:
        AppColors.navy,
        foregroundColor:
        Colors.white,
        title:
        const Text('Exams'),
      ),

      body: StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream: _firestore
            .studentProfileStream(
          user.uid,
        ),
        builder:
            (context, profileSnapshot) {
          if (!profileSnapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final batch =
              profileSnapshot
                  .data!
                  .data()?[
              'classBatch']
                  ?.toString() ??
                  '';

          return StreamBuilder<
              QuerySnapshot<
                  Map<String, dynamic>>>(
            stream: _firestore
                .studentQuizzesStream(
              batch,
            ),
            builder:
                (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Unable to load exams.',
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              final published =
              snapshot.data!.docs
                  .where(
                    (doc) {
                  final data =
                  doc.data();

                  if (data['status'] !=
                      'published') {
                    return false;
                  }

                  if (_subject != null &&
                      _subject!.isNotEmpty &&
                      _normalizeSubject(data['subject']) !=
                          _normalizeSubject(_subject)) {
                    return false;
                  }

                  return true;
                },
              ).toList();

              final practice =
              published.where(
                    (doc) =>
                doc.data()[
                'quizType'] ==
                    'practice',
              );

              final official =
              published.where(
                    (doc) =>
                doc.data()[
                'quizType'] ==
                    'official',
              );

              return ListView(
                padding:
                const EdgeInsets.all(
                  14,
                ),
                children: [
                  _subjectFilters(),

                  const SizedBox(
                    height: 16,
                  ),

                  const _Title(
                    text:
                    'PRACTICE QUIZZES',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  if (practice.isEmpty)
                    const _Empty(
                      text:
                      'No practice quizzes available.',
                    )
                  else
                    ...practice.map(
                          (doc) =>
                          _QuizCard(
                            quizId: doc.id,
                            data:
                            doc.data(),
                          ),
                    ),

                  const SizedBox(
                    height: 18,
                  ),

                  const _Title(
                    text:
                    'OFFICIAL EXAMS',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  if (official.isEmpty)
                    const _Empty(
                      text:
                      'No official exams available.',
                    )
                  else
                    ...official.map(
                          (doc) =>
                          _QuizCard(
                            quizId: doc.id,
                            data:
                            doc.data(),
                          ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );

  }
  String _normalizeSubject(dynamic value) {
    final subject =
        value?.toString().trim().toLowerCase() ?? '';

    switch (subject) {
      case 'isl':
      case 'islamiyat':
      case 'islamiat':
      case 'islamic studies':
        return 'islamiat';

      case 'web development':
      case 'web dev':
        return 'web dev';

      case 'cyber security':
      case 'cybersecurity':
        return 'cybersecurity';

      default:
        return subject;
    }
  }
  Widget _subjectFilters() {
    final values = [
      null,
      'Flutter',
      'Web Dev',
      'Cybersecurity',
      'English',
      'Islamiat',
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        itemCount:
        values.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 6,
        ),
        itemBuilder:
            (context, index) {
          final value =
          values[index];

          return ChoiceChip(
            selected:
            _subject == value,
            selectedColor:
            AppColors.student,
            label: Text(
              value ?? 'ALL',
            ),
            labelStyle:
            TextStyle(
              fontSize: 8,
              color:
              _subject == value
                  ? Colors.white
                  : AppColors
                  .textPrimary,
            ),
            onSelected: (_) {
              setState(() {
                _subject = value;
              });
            },
          );
        },
      ),
    );
  }
}

class _QuizCard
    extends StatelessWidget {
  final String quizId;
  final Map<String, dynamic> data;

  const _QuizCard({
    required this.quizId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final official =
        data['quizType'] ==
            'official';

    final questions =
        List.from(
          data['questionIds'] ?? [],
        ).length;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(13),
      decoration:
      BoxDecoration(
        color: official
            ? const Color(
          0xFFFFFAEE,
        )
            : Colors.white,
        borderRadius:
        BorderRadius.circular(
          13,
        ),
        border: Border.all(
          color: official
              ? const Color(
            0xFFFFD16B,
          )
              : const Color(
            0xFFE3E8EF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            official
                ? 'OFFICIAL'
                : 'PRACTICE',
            style:
            TextStyle(
              fontSize: 7,
              fontWeight:
              FontWeight.w700,
              color: official
                  ? Colors.orange
                  : AppColors.student,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            data['title']
                ?.toString() ??
                'Quiz',
            style:
            const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '$questions Questions • ${data['durationMinutes'] ?? 0} min',
            style:
            const TextStyle(
              color: AppColors
                  .textSecondary,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                official
                    ? Colors.orange
                    : AppColors
                    .student,
                foregroundColor:
                Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.examRules,
                  arguments:
                  quizId,
                );
              },
              child: Text(
                official
                    ? 'View Exam'
                    : 'Practice Now',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Title
    extends StatelessWidget {
  final String text;

  const _Title({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color:
        AppColors.textSecondary,
        fontSize: 9,
        fontWeight:
        FontWeight.w700,
      ),
    );
  }
}

class _Empty
    extends StatelessWidget {
  final String text;

  const _Empty({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          style:
          const TextStyle(
            color: AppColors
                .textSecondary,
          ),
        ),
      ),
    );
  }
}