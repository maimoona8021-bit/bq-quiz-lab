import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class ExamManagementScreen extends StatefulWidget {
  final String quizId;

  const ExamManagementScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<ExamManagementScreen> createState() =>
      _ExamManagementScreenState();
}

class _ExamManagementScreenState
    extends State<ExamManagementScreen> {
  final FirestoreService _firestore = FirestoreService();

  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Exam Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestore.quizStream(
          widget.quizId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load exam.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.controller,
              ),
            );
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return const Center(
              child: Text(
                'Exam not found.',
              ),
            );
          }

          final title =
              data['title']?.toString() ??
                  'Official Exam';

          final status =
              data['status']?.toString() ??
                  'pending_approval';

          final subject =
              data['subject']?.toString() ??
                  'General';

          final batch =
              data['classBatch']?.toString() ??
                  'No batch';

          final questionCount =
              List.from(
                data['questionIds'] ?? [],
              ).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              28,
            ),
            children: [
              // =====================================================
              // EXAM HEADER
              // =====================================================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius:
                  BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.controller
                            .withValues(
                          alpha: 0.16,
                        ),
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons
                            .admin_panel_settings_rounded,
                        color: AppColors.controller,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OFFICIAL EXAM',
                            style: TextStyle(
                              color:
                              AppColors.controller,
                              fontSize: 9,
                              letterSpacing: .8,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            title,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.25,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '$subject • $batch',
                            style: const TextStyle(
                              color:
                              Color(0xFFB6C0D0),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =====================================================
              // STATUS
              // =====================================================
              Row(
                children: [
                  const Text(
                    'Exam Status',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =====================================================
              // EXAM DETAILS
              // =====================================================
              _infoCard(
                icon: Icons
                    .admin_panel_settings_outlined,
                label: 'Approval Status',
                value: _statusText(status),
              ),

              _infoCard(
                icon: Icons.publish_outlined,
                label: 'Publish State',
                value: status == 'published'
                    ? 'Published to students'
                    : status ==
                    'results_released'
                    ? 'Results released'
                    : status == 'locked'
                    ? 'Exam locked'
                    : status == 'rejected'
                    ? 'Exam rejected'
                    : 'Not published',
              ),

              Row(
                children: [
                  Expanded(
                    child: _smallInfoCard(
                      icon: Icons.timer_outlined,
                      value:
                      '${data['durationMinutes'] ?? 0}',
                      label: 'Minutes',
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _smallInfoCard(
                      icon: Icons.percent_rounded,
                      value:
                      '${data['passingPercentage'] ?? 0}%',
                      label: 'Passing',
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _smallInfoCard(
                      icon: Icons.quiz_outlined,
                      value: '$questionCount',
                      label: 'Questions',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =====================================================
              // ACTIONS HEADER
              // =====================================================
              const Text(
                'Exam Actions',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Manage the official exam based on its current status.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),

              const SizedBox(height: 14),

              // =====================================================
              // ACTION CARD
              // =====================================================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(17),
                  border: Border.all(
                    color:
                    const Color(0xFFE5EAF1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.02,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (status ==
                        'pending_approval') ...[
                      _mainButton(
                        label:
                        'Approve & Publish',
                        icon: Icons
                            .check_circle_outline_rounded,
                        color:
                        AppColors.controller,
                        onPressed: user == null
                            ? null
                            : () => _approve(
                          user.uid,
                          title,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _outlineButton(
                        label: 'Reject Exam',
                        icon:
                        Icons.cancel_outlined,
                        color:
                        Colors.red.shade700,
                        onPressed: user == null
                            ? null
                            : () => _reject(
                          user.uid,
                          title,
                        ),
                      ),
                    ],

                    if (status == 'published')
                      _mainButton(
                        label: 'Lock Exam',
                        icon:
                        Icons.lock_outline_rounded,
                        color:
                        AppColors.controller,
                        onPressed: user == null
                            ? null
                            : () => _lock(
                          user.uid,
                          title,
                        ),
                      ),

                    if (status == 'locked')
                      _mainButton(
                        label: 'Release Results',
                        icon:
                        Icons.send_rounded,
                        color:
                        AppColors.controller,
                        onPressed: user == null
                            ? null
                            : () => _releaseResults(
                          user.uid,
                          title,
                        ),
                      ),

                    if (status ==
                        'results_released')
                      _CompletedMessage(
                        icon: Icons
                            .check_circle_rounded,
                        title:
                        'Results Released',
                        message:
                        'Student results are now available.',
                      ),

                    if (status == 'rejected')
                      _CompletedMessage(
                        icon:
                        Icons.cancel_rounded,
                        title: 'Exam Rejected',
                        message:
                        'This exam was rejected by the controller.',
                        danger: true,
                      ),

                    if (status !=
                        'pending_approval' &&
                        status != 'published' &&
                        status != 'locked' &&
                        status !=
                            'results_released' &&
                        status != 'rejected')
                      const _CompletedMessage(
                        icon: Icons
                            .info_outline_rounded,
                        title:
                        'No Action Available',
                        message:
                        'There are no controller actions available for the current status.',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // =====================================================
              // REPORT BUTTON
              // =====================================================
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.controllerReports,
                      arguments: widget.quizId,
                    );
                  },
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.navy,
                    side: const BorderSide(
                      color: Color(
                        0xFFD8E0EA,
                      ),
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.analytics_outlined,
                    color:
                    AppColors.controller,
                    size: 19,
                  ),
                  label: const Text(
                    'View Exam Report',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

// =====================================================
// STUDENT ATTEMPTS
// =====================================================
              const Text(
                'Student Attempts',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'View submitted attempts and reopen an attempt when necessary.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),

              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore.attemptsForQuizStream(
                  widget.quizId,
                ),
                builder: (context, attemptSnapshot) {
                  if (!attemptSnapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: AppColors.controller,
                        ),
                      ),
                    );
                  }

                  final attempts = attemptSnapshot.data!.docs;

                  if (attempts.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5EAF1),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            color: AppColors.controller,
                            size: 30,
                          ),
                          SizedBox(height: 9),
                          Text(
                            'No Student Attempts Yet',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Student attempts will appear here after they start this exam.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: attempts.map(
                          (doc) {
                        final attempt = doc.data();

                        final studentName =
                            attempt['studentName']?.toString() ??
                                'Student';

                        final attemptStatus =
                            attempt['status']
                                ?.toString() ??
                                'unknown';

                        final percentage =
                            (attempt['percentage']
                            as num?)
                                ?.round() ??
                                0;

                        final bool reopened =
                            attempt['reopened'] ==
                                true;

                        final bool resultReleased =
                            attempt['resultReleased'] ==
                                true;

// A reopened attempt has been retaken
// and submitted, but its new result is held.
                            final bool canReleaseReopenedResult =
                                reopened &&
                                    attemptStatus ==
                                        'submitted' &&
                                    !resultReleased;

// Normal submitted attempts can be reopened.
//
// If this is a reopened submitted attempt,
// we will show a Release Result button instead.
                            final bool canReopen =
                                attemptStatus ==
                                    'submitted' &&
                                    !canReleaseReopenedResult;
                        final initial = studentName.trim().isEmpty
                            ? 'S'
                            : studentName
                            .trim()[0]
                            .toUpperCase();

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5EAF1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.018,
                                ),
                                blurRadius: 9,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 21,
                                    backgroundColor:
                                    AppColors.controller.withValues(
                                      alpha: 0.13,
                                    ),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: AppColors.controller,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 11),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentName,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.navy,
                                            fontSize: 12.5,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          attemptStatus
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color:
                                            AppColors.textSecondary,
                                            fontSize: 8.5,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (attemptStatus == 'submitted')
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            resultReleased
                                                ? Colors.green
                                                .withValues(
                                              alpha: 0.09,
                                            )
                                                : AppColors
                                                .controller
                                                .withValues(
                                              alpha: 0.09,
                                            ),

                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '$percentage%',
                                            style: TextStyle(
                                              color:
                                              resultReleased
                                                  ? Colors.green
                                                  : AppColors
                                                  .controller,

                                              fontSize: 11,

                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 4,
                                        ),

                                        Text(
                                          resultReleased
                                              ? 'RELEASED'
                                              : 'HELD',
                                          style: TextStyle(
                                            color:
                                            resultReleased
                                                ? Colors.green
                                                : Colors.orange,

                                            fontSize: 7.5,

                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
// ======================================================
// REOPENED ATTEMPT:
// RELEASE THIS STUDENT'S NEW RESULT
// ======================================================

                              if (canReleaseReopenedResult) ...[
                                const SizedBox(
                                  height: 12,
                                ),

                                SizedBox(
                                  width:
                                  double.infinity,

                                  height:
                                  42,

                                  child:
                                  ElevatedButton.icon(
                                    onPressed:
                                    user == null ||
                                        _working
                                        ? null
                                        : () =>
                                        _releaseSingleResult(
                                          controllerId:
                                          user.uid,

                                          attemptId:
                                          doc.id,

                                          studentName:
                                          studentName,

                                          quizTitle:
                                          title,
                                        ),

                                    style:
                                    ElevatedButton
                                        .styleFrom(
                                      backgroundColor:
                                      AppColors
                                          .controller,

                                      foregroundColor:
                                      Colors.white,

                                      elevation:
                                      0,

                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          12,
                                        ),
                                      ),
                                    ),

                                    icon:
                                    const Icon(
                                      Icons
                                          .send_rounded,
                                      size: 17,
                                    ),

                                    label:
                                    const Text(
                                      'Release Result',

                                      style:
                                      TextStyle(
                                        fontSize:
                                        11.5,

                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (canReopen) ...[
                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 42,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.reopenAttempt,
                                        arguments: {
                                          'attemptId': doc.id,
                                          'studentName':
                                          studentName,
                                          'quizTitle': title,
                                          'currentStatus':
                                          attemptStatus,
                                        },
                                      );
                                    },
                                    style:
                                    OutlinedButton.styleFrom(
                                      foregroundColor:
                                      AppColors.controller,
                                      side: BorderSide(
                                        color: AppColors.controller
                                            .withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 17,
                                    ),
                                    label: const Text(
                                      'Reopen Attempt',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
              ),

              const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // MAIN INFO CARD
  // =========================================================

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: const Color(
            0xFFE4EAF1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.018,
            ),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.controller
                  .withValues(
                alpha: 0.09,
              ),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: AppColors.controller,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SMALL INFO CARD
  // =========================================================

  Widget _smallInfoCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: const Color(
            0xFFE4EAF1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.controller
                  .withValues(
                alpha: 0.09,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.controller,
              size: 17,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PRIMARY ACTION
  // =========================================================

  Widget _mainButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed:
        _working ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor:
          Colors.white,
          disabledBackgroundColor:
          Colors.grey.shade300,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
        icon: _working
            ? const SizedBox(
          width: 16,
          height: 16,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          icon,
          size: 19,
        ),
        label: Text(
          _working
              ? 'Please wait...'
              : label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SECONDARY ACTION
  // =========================================================

  Widget _outlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed:
        _working ? null : onPressed,
        style:
        OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: color.withValues(
              alpha: 0.45,
            ),
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _statusText(
      String status,
      ) {
    switch (status) {
      case 'pending_approval':
        return 'Waiting for controller approval';
      case 'published':
        return 'Approved and published';
      case 'locked':
        return 'Exam locked';
      case 'results_released':
        return 'Results released';
      case 'rejected':
        return 'Rejected by controller';
      default:
        return status;
    }
  }

  Future<void> _approve(
      String controllerId,
      String title,
      ) async {
    await _perform(() {
      return _firestore.approveOfficialQuiz(
        quizId: widget.quizId,
        controllerId: controllerId,
        quizTitle: title,
      );
    });
  }

  Future<void> _reject(
      String controllerId,
      String title,
      ) async {
    await _perform(() {
      return _firestore.rejectOfficialQuiz(
        quizId: widget.quizId,
        controllerId: controllerId,
        quizTitle: title,
      );
    });
  }

  Future<void> _lock(
      String controllerId,
      String title,
      ) async {
    await _perform(() {
      return _firestore.lockOfficialQuiz(
        quizId: widget.quizId,
        controllerId: controllerId,
        quizTitle: title,
      );
    });
  }

  Future<void> _releaseResults(
      String controllerId,
      String title,
      ) async {
    await _perform(() {
      return _firestore.releaseOfficialResults(
        quizId: widget.quizId,
        controllerId: controllerId,
        quizTitle: title,
      );
    });
  }
  Future<void> _releaseSingleResult({
    required String controllerId,
    required String attemptId,
    required String studentName,
    required String quizTitle,
  }) async {
    await _perform(
          () {
        return _firestore
            .releaseSingleAttemptResult(
          attemptId:
          attemptId,

          controllerId:
          controllerId,

          studentName:
          studentName,

          quizTitle:
          quizTitle,
        );
      },

      successMessage:
      '$studentName\'s result was released.',
    );
  }


  Future<void> _perform(
      Future<void> Function() action, {
        String successMessage =
        'Exam updated.',
      }) async {
    setState(() {
      _working = true;
    });

    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            successMessage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            'Unable to update: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }
  }


// =============================================================
// STATUS CHIP
// =============================================================

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending_approval':
        color = AppColors.controller;
        text = 'PENDING';
        icon = Icons.schedule_rounded;
        break;

      case 'published':
        color = AppColors.controller;
        text = 'PUBLISHED';
        icon = Icons.public_rounded;
        break;

      case 'locked':
        color = AppColors.controller;
        text = 'LOCKED';
        icon = Icons.lock_rounded;
        break;

      case 'results_released':
        color = Colors.green;
        text = 'RELEASED';
        icon = Icons.check_circle_rounded;
        break;

      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        icon = Icons.cancel_rounded;
        break;

      default:
        color = AppColors.controller;
        text = status.toUpperCase();
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.09,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight:
              FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// FINISHED/STATE MESSAGE
// =============================================================

class _CompletedMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool danger;

  const _CompletedMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Colors.red
        : AppColors.controller;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.06,
        ),
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 9.5,
                    height: 1.4,
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