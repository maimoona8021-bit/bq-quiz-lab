import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class WeakTopicsScreen extends StatelessWidget {
  const WeakTopicsScreen({
    super.key,
  });

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
          'My Weak Topics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: StreamBuilder(
        stream: firestore.studentWeakTopicsStream(
          user.uid,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.student,
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // =====================================================
          // EMPTY STATE
          // =====================================================
          if (docs.isEmpty) {
            return const _EmptyWeakTopics();
          }

          final grouped = <String, List<Map<String, dynamic>>>{};

          for (final doc in docs) {
            final data = doc.data();

            final subject =
                data['subject']?.toString() ?? 'General';

            grouped
                .putIfAbsent(
              subject,
                  () => [],
            )
                .add(data);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              28,
            ),
            children: [
              // =====================================================
              // PAGE INTRODUCTION
              // =====================================================
              const Text(
                'Saved for Review',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Questions you bookmarked while reviewing your answers will appear here.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // SUBJECT GROUPS
              // =====================================================
              ...grouped.entries.map(
                    (entry) {
                  return _SubjectCard(
                    subject: entry.key,
                    topics: entry.value,
                    onRemove: (questionId) {
                      firestore.removeWeakTopic(
                        studentId: user.uid,
                        questionId: questionId,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================
// SUBJECT CARD
// =============================================================

class _SubjectCard extends StatelessWidget {
  final String subject;
  final List<Map<String, dynamic>> topics;
  final void Function(String questionId) onRemove;

  const _SubjectCard({
    required this.subject,
    required this.topics,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3E9F1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // SUBJECT HEADER
          // =====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              13,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.student.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.student,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '${topics.length} ${topics.length == 1 ? 'saved question' : 'saved questions'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.student.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${topics.length}',
                    style: const TextStyle(
                      color: AppColors.student,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFEDF1F5),
          ),

          // =====================================================
          // QUESTIONS
          // =====================================================
          ...List.generate(
            topics.length,
                (index) {
              final topic = topics[index];

              return _WeakTopicItem(
                number: index + 1,
                questionText:
                topic['questionText']?.toString() ?? '',
                onRemove: () {
                  onRemove(
                    topic['questionId'].toString(),
                  );
                },
                showDivider: index != topics.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================
// INDIVIDUAL WEAK TOPIC
// =============================================================

class _WeakTopicItem extends StatelessWidget {
  final int number;
  final String questionText;
  final VoidCallback onRemove;
  final bool showDivider;

  const _WeakTopicItem({
    required this.number,
    required this.questionText,
    required this.onRemove,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.student.withValues(
                    alpha: 0.07,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: AppColors.student,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              // Question
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                  ),
                  child: Text(
                    questionText,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Remove
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFF6F8FB,
                    ),
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(
              left: 57,
              right: 14,
            ),
            child: Divider(
              height: 1,
              color: Color(0xFFF0F3F7),
            ),
          ),
      ],
    );
  }
}

// =============================================================
// EMPTY STATE
// =============================================================

class _EmptyWeakTopics extends StatelessWidget {
  const _EmptyWeakTopics();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.student.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.student,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Weak Topics Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Questions you bookmark as weak topics while reviewing your answers will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}