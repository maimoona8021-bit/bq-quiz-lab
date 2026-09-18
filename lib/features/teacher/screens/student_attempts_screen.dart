import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../widgets/teacher_bottom_nav.dart';

class StudentAttemptsScreen
    extends StatelessWidget {
  final String? quizId;
  final String? quizTitle;

  const StudentAttemptsScreen({
    super.key,
    this.quizId,
    this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Teacher not logged in.'),
        ),
      );
    }

    final firestore =
    FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar:
      const TeacherBottomNav(
        currentIndex: 3,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.navy,
              padding:
              const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (quizId != null)
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(
                            context,
                          ),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Student Attempts',
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 17,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                        if (quizTitle !=
                            null)
                          Text(
                            quizTitle!,
                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFFAAB6CA,
                              ),
                              fontSize:
                              9,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String,
                      dynamic>>>(
                stream: firestore
                    .teacherAttemptsStream(
                  user.uid,
                ),
                builder:
                    (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        AppColors.teacher,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load attempts.',
                      ),
                    );
                  }

                  var docs =
                      snapshot.data!.docs;

                  if (quizId != null) {
                    docs = docs
                        .where(
                          (doc) =>
                      doc.data()[
                      'quizId'] ==
                          quizId,
                    )
                        .toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No attempts yet.',
                      ),
                    );
                  }

                  final submitted =
                      docs.where((doc) {
                        return doc.data()[
                        'status'] ==
                            'submitted';
                      }).length;

                  final inProgress =
                      docs.length -
                          submitted;

                  final percentages = docs
                      .where(
                        (doc) =>
                    doc.data()[
                    'status'] ==
                        'submitted',
                  )
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
                  percentages.isEmpty
                      ? 0
                      : percentages.reduce(
                        (a, b) =>
                    a + b,
                  ) /
                      percentages
                          .length;

                  return ListView(
                    padding:
                    const EdgeInsets.all(
                      14,
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:
                            _summary(
                              '$submitted',
                              'Submitted',
                              Colors.green,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child:
                            _summary(
                              '$inProgress',
                              'In progress',
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child:
                            _summary(
                              '${average.toStringAsFixed(0)}%',
                              'Average',
                              AppColors
                                  .teacher,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      ...docs.map(
                            (doc) =>
                            _attemptCard(
                              doc.data(),
                            ),
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

  Widget _summary(
      String value,
      String label,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attemptCard(
      Map<String, dynamic> data,
      ) {
    final name =
        data['studentName']?.toString() ??
            'Student';

    final status =
        data['status']?.toString() ??
            'in_progress';

    final percentage =
        (data['percentage'] as num?)
            ?.toDouble() ??
            0;

    final seconds =
        data['timeTakenSeconds'] as int? ??
            0;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          const Color(0xFFE3E8EF),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            const Color(
              0xFF657792,
            ),
            child: Text(
              name.isEmpty
                  ? 'S'
                  : name[0]
                  .toUpperCase(),
              style:
              const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  name,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  status
                      .replaceAll(
                    '_',
                    ' ',
                  )
                      .toUpperCase(),
                  style: TextStyle(
                    color:
                    status ==
                        'submitted'
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                status == 'submitted'
                    ? '${percentage.toStringAsFixed(0)}%'
                    : '—',
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatTime(seconds),
                style:
                const TextStyle(
                  color: AppColors
                      .textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '';

    final minutes =
        seconds ~/ 60;

    final remaining =
        seconds % 60;

    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }
}