import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class AddEditQuestionScreen
    extends StatefulWidget {
  final String? questionId;

  const AddEditQuestionScreen({
    super.key,
    this.questionId,
  });

  bool get isEditing => questionId != null;

  @override
  State<AddEditQuestionScreen> createState() =>
      _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState
    extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _subject = TextEditingController();
  final _question = TextEditingController();
  final _explanation = TextEditingController();

  final List<TextEditingController>
  _options = List.generate(
    4,
        (_) => TextEditingController(),
  );

  final FirestoreService _firestore =
  FirestoreService();

  String _difficulty = 'medium';
  int _correctIndex = 0;

  bool _loading = false;
  bool _loadingQuestion = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      _loadQuestion();
    }
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _loadingQuestion = true;
    });

    try {
      final doc = await _firestore.getQuestion(
        widget.questionId!,
      );

      final data = doc.data();

      if (data == null) return;

      _subject.text =
          data['subject']?.toString() ?? '';

      _question.text =
          data['questionText']?.toString() ?? '';

      _explanation.text =
          data['explanation']?.toString() ?? '';

      _difficulty =
          data['difficulty']?.toString() ??
              'medium';

      _correctIndex =
          data['correctIndex'] as int? ?? 0;

      final options =
      List<String>.from(
        data['options'] ?? [],
      );

      for (int i = 0;
      i < options.length && i < 4;
      i++) {
        _options[i].text = options[i];
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingQuestion = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final optionValues = _options
          .map((e) => e.text.trim())
          .toList();

      if (widget.isEditing) {
        await _firestore.updateQuestion(
          questionId: widget.questionId!,
          subject: _subject.text,
          difficulty: _difficulty,
          questionText: _question.text,
          options: optionValues,
          correctIndex: _correctIndex,
          explanation:
          _explanation.text,
        );
      } else {
        await _firestore.createQuestion(
          teacherId: user.uid,
          subject: _subject.text,
          difficulty: _difficulty,
          questionText: _question.text,
          options: optionValues,
          correctIndex: _correctIndex,
          explanation:
          _explanation.text,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save question: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingQuestion) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.teacher,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          widget.isEditing
              ? 'Edit Question'
              : 'Add Question',
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Subject'),

            TextFormField(
              controller: _subject,
              decoration:
              _input('e.g. Flutter'),
              validator: _required,
            ),

            const SizedBox(height: 16),

            _label('Difficulty'),

            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: _input('Difficulty'),
              items: const [
                DropdownMenuItem(
                  value: 'easy',
                  child: Text('Easy'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'hard',
                  child: Text('Hard'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _difficulty = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            _label('Question'),

            TextFormField(
              controller: _question,
              maxLines: 4,
              decoration: _input(
                'Type the question...',
              ),
              validator: _required,
            ),

            const SizedBox(height: 20),

            const Text(
              'OPTIONS — TAP LETTER TO MARK CORRECT',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            ...List.generate(
              4,
                  (index) => Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _correctIndex = index;
                        });
                      },
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment:
                        Alignment.center,
                        decoration: BoxDecoration(
                          color:
                          _correctIndex ==
                              index
                              ? AppColors
                              .teacher
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                          border: Border.all(
                            color: _correctIndex ==
                                index
                                ? AppColors.teacher
                                : const Color(
                              0xFFDCE3EC,
                            ),
                          ),
                        ),
                        child: Text(
                          String.fromCharCode(
                            65 + index,
                          ),
                          style: TextStyle(
                            color:
                            _correctIndex ==
                                index
                                ? Colors.white
                                : AppColors
                                .textPrimary,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: TextFormField(
                        controller:
                        _options[index],
                        decoration: _input(
                          'Option ${String.fromCharCode(65 + index)}',
                        ),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            _label('Explanation'),

            TextFormField(
              controller: _explanation,
              maxLines: 4,
              decoration: _input(
                'Explain why the answer is correct...',
              ),
              validator: _required,
            ),

            const SizedBox(height: 26),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                _loading ? null : _save,
                icon: Icon(
                  widget.isEditing
                      ? Icons.save_rounded
                      : Icons.add_rounded,
                ),
                style: ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  AppColors.teacher,
                  foregroundColor:
                  Colors.white,
                ),
                label: _loading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  widget.isEditing
                      ? 'Update Question'
                      : 'Add Question',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  Widget _label(String label) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFDCE3EC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFDCE3EC),
        ),
      ),
    );
  }
}