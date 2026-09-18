import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../widgets/teacher_bottom_nav.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() =>
      _QuestionBankScreenState();
}

class _QuestionBankScreenState
    extends State<QuestionBankScreen> {
  final FirestoreService _firestore = FirestoreService();

  String _search = '';
  String _subject = 'All';
  String _difficulty = 'All';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Teacher not logged in.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: const TeacherBottomNav(
        currentIndex: 1,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.teacher,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addQuestion,
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Question'),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _header(),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore.teacherQuestionsStream(
                  user.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load questions.',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.teacher,
                      ),
                    );
                  }

                  final allDocs = snapshot.data!.docs;

                  final subjects = <String>{'All'};

                  for (final doc in allDocs) {
                    final subject =
                    doc.data()['subject']?.toString();

                    if (subject != null &&
                        subject.trim().isNotEmpty) {
                      subjects.add(subject.trim());
                    }
                  }

                  final docs = allDocs.where((doc) {
                    final data = doc.data();

                    final question =
                        data['questionText']
                            ?.toString()
                            .toLowerCase() ??
                            '';

                    final subject =
                        data['subject']?.toString() ?? '';

                    final difficulty =
                        data['difficulty']
                            ?.toString()
                            .toLowerCase() ??
                            '';

                    final searchMatches =
                    question.contains(
                      _search.toLowerCase(),
                    );

                    final subjectMatches =
                        _subject == 'All' ||
                            subject == _subject;

                    final difficultyMatches =
                        _difficulty == 'All' ||
                            difficulty ==
                                _difficulty
                                    .toLowerCase();

                    return searchMatches &&
                        subjectMatches &&
                        difficultyMatches;
                  }).toList();

                  docs.sort((a, b) {
                    final aTime =
                    a.data()['createdAt'];

                    final bTime =
                    b.data()['createdAt'];

                    if (aTime is Timestamp &&
                        bTime is Timestamp) {
                      return bTime.compareTo(aTime);
                    }

                    return 0;
                  });

                  return Column(
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(
                          14,
                          14,
                          14,
                          4,
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _search = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                            'Search questions...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                              borderSide:
                              BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      _subjectFilters(
                        subjects.toList(),
                      ),

                      _difficultyFilters(),

                      Expanded(
                        child: docs.isEmpty
                            ? _emptyState(
                          allDocs.isEmpty,
                        )
                            : ListView.separated(
                          padding:
                          const EdgeInsets
                              .fromLTRB(
                            14,
                            8,
                            14,
                            100,
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
                            return _questionCard(
                              docs[index],
                            );
                          },
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

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: const Row(
        children: [
          Icon(
            Icons.question_answer_rounded,
            color: Color(0xFF65D7C9),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Question Bank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Manage your quiz questions',
                  style: TextStyle(
                    color: Color(0xFFAAB6CA),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectFilters(
      List<String> subjects,
      ) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding:
        const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final subject = subjects[index];

          return ChoiceChip(
            label: Text(subject),
            selected: _subject == subject,
            selectedColor:
            AppColors.teacher,
            labelStyle: TextStyle(
              fontSize: 10,
              color: _subject == subject
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            onSelected: (_) {
              setState(() {
                _subject = subject;
              });
            },
          );
        },
      ),
    );
  }

  Widget _difficultyFilters() {
    final difficulties = [
      'All',
      'Easy',
      'Medium',
      'Hard',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding:
        const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: difficulties.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final item = difficulties[index];

          return ChoiceChip(
            label: Text(item),
            selected: _difficulty == item,
            onSelected: (_) {
              setState(() {
                _difficulty = item;
              });
            },
          );
        },
      ),
    );
  }

  Widget _questionCard(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    final subject =
        data['subject']?.toString() ?? 'General';

    final difficulty =
        data['difficulty']?.toString() ?? 'easy';

    final question =
        data['questionText']?.toString() ??
            'Question';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE3E8EF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(
                subject.toUpperCase(),
                const Color(0xFFE8F8F5),
                AppColors.teacher,
              ),

              const SizedBox(width: 6),

              _badge(
                difficulty.toUpperCase(),
                _difficultyBackground(
                  difficulty,
                ),
                _difficultyColor(
                  difficulty,
                ),
              ),

              const Spacer(),

              _roundIcon(
                Icons.edit_rounded,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editQuestion,
                    arguments: doc.id,
                  );
                },
              ),

              const SizedBox(width: 6),

              _roundIcon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                onTap: () =>
                    _confirmDelete(doc.id),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(
      IconData icon, {
        required VoidCallback onTap,
        Color color = AppColors.teacher,
      }) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _badge(
      String text,
      Color background,
      Color foreground,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyState(bool completelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz_outlined,
              size: 55,
              color: Color(0xFF9CA8B9),
            ),
            const SizedBox(height: 12),
            Text(
              completelyEmpty
                  ? 'No questions yet'
                  : 'No matching questions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              completelyEmpty
                  ? 'Add your first question to build your question bank.'
                  : 'Try changing the search or filters.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      String id,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          const Text('Delete Question?'),
          content: const Text(
            'This question will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style:
                TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _firestore.deleteQuestion(id);
    }
  }

  Color _difficultyColor(
      String difficulty,
      ) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _difficultyBackground(
      String difficulty,
      ) {
    return _difficultyColor(difficulty)
        .withValues(alpha: 0.10);
  }
}