import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class StudentNotificationsScreen
    extends StatelessWidget {
  const StudentNotificationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    final firestore =
    FirestoreService();

    if (user == null) {
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        backgroundColor:
        AppColors.navy,
        foregroundColor:
        Colors.white,
        title:
        const Text(
          'Notifications',
        ),
      ),

      body: StreamBuilder(
        stream: firestore
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
            stream: firestore
                .studentNotificationsStream(
              batch,
            ),
            builder:
                (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              final docs =
              snapshot.data!.docs
                  .where(
                    (doc) =>
                doc.data()[
                'audienceRole'] ==
                    'student',
              ).toList();

              docs.sort(
                    (a, b) {
                  final at =
                  a.data()[
                  'createdAt'];
                  final bt =
                  b.data()[
                  'createdAt'];

                  if (at is Timestamp &&
                      bt is Timestamp) {
                    return bt
                        .compareTo(at);
                  }

                  return 0;
                },
              );

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications yet.',
                  ),
                );
              }

              return ListView.separated(
                padding:
                const EdgeInsets.all(
                  14,
                ),
                itemCount:
                docs.length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  height: 8,
                ),
                itemBuilder:
                    (context, index) {
                  final doc =
                  docs[index];

                  final data =
                  doc.data();

                  final readBy =
                  List<String>.from(
                    data['readBy'] ??
                        [],
                  );

                  final unread =
                  !readBy.contains(
                    user.uid,
                  );

                  return Dismissible(
                    key: ValueKey(doc.id),

                    direction: DismissDirection.endToStart,

                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text(
                              'Delete notification?',
                            ),
                            content: const Text(
                              'This notification will be permanently deleted.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
                                    false,
                                  );
                                },
                                child: const Text(
                                  'Cancel',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
                                    true,
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ) ??
                          false;
                    },

                    onDismissed: (direction) async {
                      try {
                        await firestore
                            .deleteStudentNotification(
                          doc.id,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notification deleted',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to delete notification.',
                            ),
                          ),
                        );
                      }
                    },

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    child: InkWell(
                      onTap: () async {
                        await firestore
                            .markStudentNotificationRead(
                          notificationId: doc.id,
                          studentId: user.uid,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        final quizId =
                        data['quizId']?.toString();

                        if (quizId == null ||
                            quizId.isEmpty) {
                          return;
                        }

                        if (data['type'] ==
                            'official_results_released') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.attemptHistory,
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.examRules,
                            arguments: quizId,
                          );
                        }
                      },

                      child: Container(
                        padding: const EdgeInsets.all(
                          13,
                        ),
                        decoration: BoxDecoration(
                          color: unread
                              ? const Color(
                            0xFFEEF4FF,
                          )
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: unread
                                ? AppColors.student
                                : const Color(
                              0xFFE4E9F0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                              AppColors.student.withValues(
                                alpha: 0.1,
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                color: AppColors.student,
                                size: 17,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title']?.toString() ??
                                        'Notification',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: unread
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 3,
                                  ),

                                  Text(
                                    data['message']?.toString() ??
                                        '',
                                    style: const TextStyle(
                                      color:
                                      AppColors.textSecondary,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (unread)
                              Container(
                                width: 7,
                                height: 7,
                                decoration:
                                const BoxDecoration(
                                  color: AppColors.student,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );                },
              );
            },
          );
        },
      ),
    );
  }
}