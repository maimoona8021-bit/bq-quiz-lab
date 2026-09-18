import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class ReopenAttemptScreen
    extends StatefulWidget {
  final String attemptId;
  final String studentName;
  final String quizTitle;
  final String currentStatus;

  const ReopenAttemptScreen({
    super.key,
    required this.attemptId,
    required this.studentName,
    required this.quizTitle,
    required this.currentStatus,
  });

  @override
  State<ReopenAttemptScreen> createState() =>
      _ReopenAttemptScreenState();
}

class _ReopenAttemptScreenState
    extends State<ReopenAttemptScreen> {
  final TextEditingController
  _reasonController =
  TextEditingController();

  final FirestoreService _firestore =
  FirestoreService();

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title:
        const Text('Reopen Attempt'),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    AppColors.controller,
                    child: Text(
                      widget.studentName
                          .isEmpty
                          ? 'S'
                          : widget
                          .studentName[0]
                          .toUpperCase(),
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          widget.studentName,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                        Text(
                          widget.quizTitle,
                          style:
                          const TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Column(
                children: [
                  _detail(
                    'Exam',
                    widget.quizTitle,
                  ),
                  const Divider(),
                  _detail(
                    'Current status',
                    widget.currentStatus
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                'Reason for reopening',
                style:
                const TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller:
              _reasonController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                'Explain why this attempt should be reopened...',
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:
                    const Text('Cancel',style: TextStyle(color: AppColors.controller),),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child:
                  ElevatedButton.icon(
                    onPressed: _saving
                        ? null
                        : _reopen,
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      AppColors.controller,
                      foregroundColor:
                      Colors.white,
                    ),
                    icon: const Icon(
                      Icons
                          .refresh_rounded,
                    ),
                    label: const Text(
                      'Reopen Attempt',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(
      String label,
      String value,
      ) {
    return Row(
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color:
            AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _reopen() async {
    final reason =
    _reasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a reason.',
          ),
        ),
      );

      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _saving = true;
    });

    try {
      await _firestore.reopenAttempt(
        attemptId: widget.attemptId,
        controllerId: user.uid,
        studentName:
        widget.studentName,
        quizTitle:
        widget.quizTitle,
        reason: reason,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}