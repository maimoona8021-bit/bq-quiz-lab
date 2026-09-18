import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class CreateQuizScreen
    extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() =>
      _CreateQuizScreenState();
}

class _CreateQuizScreenState
    extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _description =
  TextEditingController();
  final _batch = TextEditingController();

  final FirestoreService _firestore =
  FirestoreService();

  String? _subject;
  String _quizType = 'practice';

  int _duration = 20;
  int _passing = 60;

  bool _leaderboardVisible = true;
  bool _saving = false;

  final Set<String> _selectedQuestions =
  {};

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

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Create Quiz'),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .teacherQuestionsStream(user.uid),
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
              child:
              CircularProgressIndicator(
                color: AppColors.teacher,
              ),
            );
          }

          final allQuestions =
              snapshot.data!.docs;

          final subjects = <String>{};

          for (final doc in allQuestions) {
            final subject =
            doc.data()['subject']
                ?.toString();

            if (subject != null &&
                subject.isNotEmpty) {
              subjects.add(subject);
            }
          }

          final visibleQuestions =
          _subject == null
              ? allQuestions
              : allQuestions
              .where(
                (doc) =>
            doc.data()[
            'subject'] ==
                _subject,
          )
              .toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [
                _label('Quiz title'),

                TextFormField(
                  controller: _title,
                  decoration:
                  _input('Quiz title'),
                  validator: _required,
                ),

                const SizedBox(height: 14),

                _label('Description'),

                TextFormField(
                  controller:
                  _description,
                  maxLines: 3,
                  decoration: _input(
                    'Describe this quiz...',
                  ),
                  validator: _required,
                ),

                const SizedBox(height: 14),

                _label('Subject'),

                DropdownButtonFormField<
                    String>(
                  initialValue: _subject,
                  decoration:
                  _input('Select subject'),
                  items: subjects
                      .map(
                        (subject) =>
                        DropdownMenuItem(
                          value: subject,
                          child:
                          Text(subject),
                        ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _subject = value;

                      _selectedQuestions
                          .clear();
                    });
                  },
                  validator: (value) =>
                  value == null
                      ? 'Select subject'
                      : null,
                ),

                const SizedBox(height: 18),

                _label('Quiz type'),

                Row(
                  children: [
                    Expanded(
                      child: _typeButton(
                        'Practice',
                        'practice',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: _typeButton(
                        'Official',
                        'official',
                      ),
                    ),
                  ],
                ),

                if (_quizType ==
                    'official')
                  const Padding(
                    padding:
                    EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      'Official quizzes remain in draft until controller approval.',
                      style: TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          _label('Duration'),

                          DropdownButtonFormField<
                              int>(
                            initialValue:
                            _duration,
                            decoration:
                            _input(
                              'Duration',
                            ),
                            items: const [
                              10,
                              15,
                              20,
                              30,
                              45,
                              60,
                            ]
                                .map(
                                  (value) =>
                                  DropdownMenuItem(
                                    value:
                                    value,
                                    child: Text(
                                      '$value minutes',
                                    ),
                                  ),
                            )
                                .toList(),
                            onChanged:
                                (value) {
                              if (value !=
                                  null) {
                                setState(() {
                                  _duration =
                                      value;
                                });
                              }
                            },
                          ),
                        ],
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
                          _label('Passing %'),

                          DropdownButtonFormField<
                              int>(
                            initialValue:
                            _passing,
                            decoration:
                            _input(
                              'Passing',
                            ),
                            items: const [
                              50,
                              60,
                              70,
                              80,
                            ]
                                .map(
                                  (value) =>
                                  DropdownMenuItem(
                                    value:
                                    value,
                                    child: Text(
                                      '$value%',
                                    ),
                                  ),
                            )
                                .toList(),
                            onChanged:
                                (value) {
                              if (value !=
                                  null) {
                                setState(() {
                                  _passing =
                                      value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _label('Class / Batch'),

                TextFormField(
                  controller: _batch,
                  decoration:
                  _input('e.g. Batch 14'),
                  validator: _required,
                ),

                const SizedBox(height: 10),

                SwitchListTile(
                  contentPadding:
                  EdgeInsets.zero,
                  title: const Text(
                    'Show leaderboard',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Students can see rankings after submission.',
                    style:
                    TextStyle(fontSize: 10),
                  ),
                  value:
                  _leaderboardVisible,
                  activeThumbColor:
                  AppColors.teacher,
                  onChanged: (value) {
                    setState(() {
                      _leaderboardVisible =
                          value;
                    });
                  },
                ),

                const Divider(),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'SELECT QUESTIONS',
                        style: TextStyle(
                          color: AppColors
                              .textSecondary,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_selectedQuestions.length} of 20 selected',
                      style: const TextStyle(
                        color:
                        AppColors.teacher,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (_subject == null)
                  const Padding(
                    padding:
                    EdgeInsets.all(20),
                    child: Text(
                      'Select a subject to choose questions.',
                      textAlign:
                      TextAlign.center,
                    ),
                  )
                else if (visibleQuestions
                    .isEmpty)
                  const Padding(
                    padding:
                    EdgeInsets.all(20),
                    child: Text(
                      'No questions found for this subject.',
                      textAlign:
                      TextAlign.center,
                    ),
                  )
                else
                  ...visibleQuestions.map(
                        (doc) {
                      final data =
                      doc.data();

                      final selected =
                      _selectedQuestions
                          .contains(
                        doc.id,
                      );

                      return CheckboxListTile(
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 4,
                        ),
                        value: selected,
                        activeColor:
                        AppColors.teacher,
                        title: Text(
                          data['questionText']
                              ?.toString() ??
                              '',
                          style:
                          const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          data['difficulty']
                              ?.toString()
                              .toUpperCase() ??
                              '',
                          style:
                          const TextStyle(
                            fontSize: 9,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value ==
                                true) {
                              if (_selectedQuestions
                                  .length >=
                                  20) {
                                ScaffoldMessenger
                                    .of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Maximum 20 questions.',
                                    ),
                                  ),
                                );

                                return;
                              }

                              _selectedQuestions
                                  .add(
                                doc.id,
                              );
                            } else {
                              _selectedQuestions
                                  .remove(
                                doc.id,
                              );
                            }
                          });
                        },
                      );
                    },
                  ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                    _saving
                        ? null
                        : () =>
                        _save(
                          user.uid,
                        ),
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      AppColors.teacher,
                      foregroundColor:
                      Colors.white,
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Text(
                      'Create Quiz',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(
      String teacherId,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedQuestions.length < 10 ||
        _selectedQuestions.length > 20) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select between 10 and 20 questions.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore.createQuiz(
        teacherId: teacherId,
        title: _title.text,
        description:
        _description.text,
        subject: _subject!,
        quizType: _quizType,
        durationMinutes: _duration,
        passingPercentage: _passing,
        classBatch: _batch.text,
        questionIds:
        _selectedQuestions.toList(),
        leaderboardVisible:
        _leaderboardVisible,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.myQuizzes,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _typeButton(
      String text,
      String value,
      ) {
    final selected =
        _quizType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _quizType = value;
        });
      },
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.teacher
              : Colors.white,
          borderRadius:
          BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.teacher
                : const Color(0xFFDCE3EC),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? Colors.white
                : AppColors.textPrimary,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String? _required(
      String? value,
      ) {
    return value == null ||
        value.trim().isEmpty
        ? 'Required'
        : null;
  }

  Widget _label(String text) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _input(
      String hint,
      ) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }
}