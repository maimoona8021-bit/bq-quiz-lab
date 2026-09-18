import 'dart:async';

import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/firestore_service.dart';
import 'review_before_submit_screen.dart';

class QuizPlayerScreen extends StatefulWidget {
  final String quizId;
  final String attemptId;

  const QuizPlayerScreen({
    super.key,
    required this.quizId,
    required this.attemptId,
  });

  @override
  State<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends State<QuizPlayerScreen> {
  final FirestoreService _firestore = FirestoreService();

  Map<String, dynamic>? _quiz;

  List<Map<String, dynamic>> _questions = [];

  final Map<String, int> _answers = {};

  final Set<String> _flagged = {};

  int _index = 0;

  int _remainingSeconds = 0;
  int _totalSeconds = 0;

  Timer? _timer;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final quizSnapshot = await _firestore.getQuiz(
      widget.quizId,
    );

    if (!quizSnapshot.exists) {
      return;
    }

    final quiz = quizSnapshot.data()!;

    final ids = List<String>.from(
      quiz['questionIds'] ?? [],
    );

    final questions = await _firestore.getQuestionsByIds(
      ids,
    );

    final minutes =
        (quiz['durationMinutes'] as num?)?.toInt() ?? 10;

    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;

    if (!mounted) return;

    setState(() {
      _quiz = quiz;
      _questions = questions;
      _loading = false;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (_remainingSeconds <= 1) {
          _timer?.cancel();

          setState(() {
            _remainingSeconds = 0;
          });

          _submit(
            autoSubmit: true,
          );

          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty || _quiz == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No questions found.',
          ),
        ),
      );
    }

    final question = _questions[_index];

    final questionId = question['id'].toString();

    final options = List<String>.from(
      question['options'] ?? [],
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _header(),

              LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                minHeight: 5,
                backgroundColor: const Color(0xFFE1E7EF),
                color: AppColors.student,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============================
                      // QUESTION LABEL
                      // ============================

                      Text(
                        'QUESTION ${_index + 1}',
                        style: const TextStyle(
                          color: AppColors.student,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .7,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ============================
                      // QUESTION CARD
                      // ============================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE7ECF2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.025),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          question['questionText']
                              ?.toString() ??
                              '',
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Choose an answer',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ============================
                      // ANSWERS
                      // ============================

                      ...List.generate(
                        options.length,
                            (optionIndex) {
                          final selected =
                              _answers[questionId] ==
                                  optionIndex;

                          return Padding(
                            padding:
                            const EdgeInsets.only(
                              bottom: 11,
                            ),
                            child: InkWell(
                              borderRadius:
                              BorderRadius.circular(14),
                              onTap: () {
                                setState(() {
                                  _answers[questionId] =
                                      optionIndex;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 150,
                                ),
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.student
                                      .withOpacity(.07)
                                      : Colors.white,
                                  border: Border.all(
                                    width: selected ? 1.5 : 1,
                                    color: selected
                                        ? AppColors.student
                                        : const Color(
                                      0xFFDDE4ED,
                                    ),
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  boxShadow: selected
                                      ? [
                                    BoxShadow(
                                      color: AppColors
                                          .student
                                          .withOpacity(.07),
                                      blurRadius: 10,
                                      offset:
                                      const Offset(
                                        0,
                                        3,
                                      ),
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      alignment:
                                      Alignment.center,
                                      decoration:
                                      BoxDecoration(
                                        shape:
                                        BoxShape.circle,
                                        color: selected
                                            ? AppColors
                                            .student
                                            : const Color(
                                          0xFFF3F6FA,
                                        ),
                                      ),
                                      child: Text(
                                        String.fromCharCode(
                                          65 + optionIndex,
                                        ),
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : AppColors.navy,
                                          fontSize: 11,
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 13,
                                    ),

                                    Expanded(
                                      child: Text(
                                        options[optionIndex],
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.35,
                                          fontWeight:
                                          selected
                                              ? FontWeight
                                              .w600
                                              : FontWeight
                                              .w400,
                                          color:
                                          AppColors.navy,
                                        ),
                                      ),
                                    ),

                                    if (selected)
                                      const Padding(
                                        padding:
                                        EdgeInsets.only(
                                          left: 8,
                                        ),
                                        child: Icon(
                                          Icons
                                              .check_circle_rounded,
                                          color:
                                          AppColors.student,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _header() {
    final currentQuestionId =
    _questions[_index]['id'].toString();

    final isFlagged =
    _flagged.contains(currentQuestionId);

    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        13,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      _quiz?['title']?.toString() ??
                          'Quiz',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(.09),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatTime(
                              _remainingSeconds,
                            ),
                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                              letterSpacing: .5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  onPressed: () {
                    final id =
                    _questions[_index]['id']
                        .toString();

                    setState(() {
                      if (_flagged.contains(id)) {
                        _flagged.remove(id);
                      } else {
                        _flagged.add(id);
                      }
                    });
                  },
                  icon: Icon(
                    isFlagged
                        ? Icons.flag_rounded
                        : Icons.flag_outlined,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                'Question ${_index + 1} of ${_questions.length}',
                style: const TextStyle(
                  color: Color(0xFFB9C3D5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${((_index + 1) / _questions.length * 100).round()}% complete',
                style: const TextStyle(
                  color: Color(0xFFB9C3D5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM ACTION AREA
  // =========================================================

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigator + Review
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _showNavigator,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD9E0EA),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Navigator',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _openReview,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD9E0EA),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.fact_check_outlined,
                      size: 16,
                    ),
                    label: const Text(
                      'Review',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Previous + Next
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _index == 0
                        ? null
                        : () {
                      setState(() {
                        _index--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      disabledForegroundColor:
                      Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      side: BorderSide(
                        color: _index == 0
                            ? Colors.grey.shade200
                            : const Color(0xFFD9E0EA),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Previous',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.student,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_index <
                          _questions.length - 1) {
                        setState(() {
                          _index++;
                        });
                      } else {
                        _openReview();
                      }
                    },
                    iconAlignment: IconAlignment.end,
                    icon: Icon(
                      _index ==
                          _questions.length - 1
                          ? Icons.fact_check_outlined
                          : Icons.arrow_forward_rounded,
                      size: 17,
                    ),
                    label: Text(
                      _index ==
                          _questions.length - 1
                          ? 'Review'
                          : 'Next',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ORIGINAL FUNCTIONALITY BELOW
  // =========================================================

  Future<void> _openReview() async {
    final answeredIndices = <int>{};

    final flaggedIndices = <int>{};

    for (int i = 0; i < _questions.length; i++) {
      final id =
      _questions[i]['id'].toString();

      if (_answers.containsKey(id)) {
        answeredIndices.add(i);
      }

      if (_flagged.contains(id)) {
        flaggedIndices.add(i);
      }
    }

    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReviewBeforeSubmitScreen(
              totalQuestions:
              _questions.length,
              answered:
              answeredIndices,
              flagged:
              flaggedIndices,
            ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result == -1) {
      _confirmSubmit();
      return;
    }

    setState(() {
      _index = result;
    });
  }

  void _showNavigator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                    Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Question Navigator',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Select a question to jump directly to it.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 18),

              GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final id =
                  _questions[index]['id']
                      .toString();

                  final answered =
                  _answers.containsKey(id);

                  final flagged =
                  _flagged.contains(id);

                  Color color =
                  const Color(0xFFD9E1EB);

                  if (answered) {
                    color = Colors.green;
                  }

                  if (flagged) {
                    color = Colors.orange;
                  }

                  if (_index == index) {
                    color =
                        AppColors.student;
                  }

                  return InkWell(
                    borderRadius:
                    BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        _index = index;
                      });
                    },
                    child: Container(
                      alignment:
                      Alignment.center,
                      decoration: BoxDecoration(
                        color: _index == index
                            ? AppColors.student
                            .withOpacity(.08)
                            : Colors.white,
                        border: Border.all(
                          width:
                          _index == index
                              ? 1.5
                              : 1,
                          color: color,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color:
                          AppColors.navy,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmSubmit() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Submit Quiz?',
          ),
          content: const Text(
            'You will not be able to change your answers after submission.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',style: TextStyle(color: AppColors.student),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Submit',style: TextStyle(color: AppColors.student),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _submit();
    }
  }

  Future<void> _submit({
    bool autoSubmit = false,
  }) async {
    if (_submitting) return;

    _timer?.cancel();

    setState(() {
      _submitting = true;
    });

    int correct = 0;

    for (final question in _questions) {
      final id =
      question['id'].toString();

      final selected = _answers[id];

      final correctIndex =
      (question['correctIndex'] as num?)
          ?.toInt();

      if (selected != null &&
          selected == correctIndex) {
        correct++;
      }
    }

    final percentage =
    _questions.isEmpty
        ? 0
        : ((correct /
        _questions.length) *
        100)
        .round();

    final timeUsed =
        _totalSeconds -
            _remainingSeconds;

    await _firestore
        .submitStudentAttempt(
      attemptId: widget.attemptId,
      answers: _answers,
      flaggedQuestionIds:
      _flagged.toList(),
      score: correct,
      percentage: percentage,
      timeTakenSeconds: timeUsed,
    );

    if (!mounted) return;

    final official =
        _quiz?['quizType'] ==
            'official';

    Navigator.pushNamedAndRemoveUntil(
      context,
      official
          ? AppRoutes
          .officialResultWaiting
          : AppRoutes.result,
          (route) => route.isFirst,
      arguments: {
        'attemptId': widget.attemptId,
        'quizId': widget.quizId,
      },
    );
  }

  String _formatTime(
      int seconds,
      ) {
    final minutes = seconds ~/ 60;

    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}