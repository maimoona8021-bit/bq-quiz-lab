import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class ControllerNotificationsScreen
    extends StatelessWidget {
  const ControllerNotificationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final firestore =
    FirestoreService();

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        backgroundColor:
        AppColors.navy,
        foregroundColor:
        Colors.white,

        title: const Text(
          'Notifications',
        ),

        actions: [
          TextButton(
            onPressed: () async {
              await firestore
                  .markAllControllerNotificationsAsRead();
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color:
                AppColors.controller,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: firestore
            .controllerNotificationsStream(),

        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load notifications.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                AppColors.controller,
              ),
            );
          }

          final docs =
          [...snapshot.data!.docs];

          docs.sort(
                (a, b) {
              final aTime =
              a.data()['createdAt'];

              final bTime =
              b.data()['createdAt'];

              if (aTime is Timestamp &&
                  bTime is Timestamp) {
                return bTime
                    .compareTo(aTime);
              }

              return 0;
            },
          );

          if (docs.isEmpty) {
            return const _EmptyNotifications();
          }

          return ListView.separated(
            padding:
            const EdgeInsets.all(14),

            itemCount:
            docs.length,

            separatorBuilder:
                (_, __) =>
            const SizedBox(
              height: 9,
            ),

            itemBuilder:
                (context, index) {
              final doc =
              docs[index];

              final data =
              doc.data();

              return _NotificationCard(
                data: data,

                onTap: () async {
                  await firestore
                      .markNotificationAsRead(
                    doc.id,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  final quizId =
                  data['quizId']
                      ?.toString();

                  if (quizId != null &&
                      quizId.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes
                          .examManagement,
                      arguments:
                      quizId,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard
    extends StatelessWidget {
  final Map<String, dynamic> data;

  final VoidCallback onTap;

  const _NotificationCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead =
        data['isRead'] == true;

    final Timestamp? timestamp =
    data['createdAt']
    is Timestamp
        ? data['createdAt']
    as Timestamp
        : null;

    return Material(
      color: isRead
          ? Colors.white
          : const Color(
        0xFFFFF8E8,
      ),

      borderRadius:
      BorderRadius.circular(14),

      child: InkWell(
        onTap: onTap,

        borderRadius:
        BorderRadius.circular(14),

        child: Container(
          padding:
          const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            border: Border.all(
              color: isRead
                  ? const Color(
                0xFFE4E9F0,
              )
                  : AppColors
                  .controller
                  .withValues(
                alpha: 0.35,
              ),
            ),
          ),

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Container(
                width: 42,
                height: 42,

                decoration:
                BoxDecoration(
                  color: AppColors
                      .controller
                      .withValues(
                    alpha: 0.13,
                  ),

                  borderRadius:
                  BorderRadius
                      .circular(
                    12,
                  ),
                ),

                child: const Icon(
                  Icons
                      .pending_actions_rounded,

                  color:
                  AppColors.controller,

                  size: 20,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['title']
                                ?.toString() ??
                                'Notification',

                            style:
                            TextStyle(
                              fontSize: 12,

                              fontWeight:
                              isRead
                                  ? FontWeight
                                  .w600
                                  : FontWeight
                                  .w800,
                            ),
                          ),
                        ),

                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,

                            decoration:
                            const BoxDecoration(
                              color: AppColors
                                  .controller,

                              shape:
                              BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      data['message']
                          ?.toString() ??
                          '',

                      style:
                      const TextStyle(
                        color: AppColors
                            .textSecondary,

                        fontSize: 10,

                        height: 1.4,
                      ),
                    ),

                    if (timestamp !=
                        null) ...[
                      const SizedBox(
                        height: 7,
                      ),

                      Text(
                        _formatTime(
                          timestamp.toDate(),
                        ),

                        style:
                        const TextStyle(
                          color: Color(
                            0xFF98A3B3,
                          ),

                          fontSize: 8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,

                color:
                Color(0xFF9AA6B7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(
      DateTime date,
      ) {
    final now =
    DateTime.now();

    final difference =
    now.difference(date);

    if (difference.inMinutes <
        1) {
      return 'Just now';
    }

    if (difference.inMinutes <
        60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours <
        24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays <
        7) {
      return '${difference.inDays}d ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyNotifications
    extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            Icons
                .notifications_none_rounded,

            size: 55,

            color:
            Color(0xFF99A6B8),
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'No notifications yet',

            style: TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 4,
          ),

          Text(
            'Official quiz approvals will appear here.',

            style: TextStyle(
              color: AppColors
                  .textSecondary,

              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}