import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ widgets/controller_bottom_nav.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class ControllerDashboardScreen extends StatelessWidget {
  const ControllerDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No active controller session.',
          ),
        ),
      );
    }

    final firestore =
    FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar:
      const ControllerBottomNav(
        currentIndex: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<
                DocumentSnapshot<
                    Map<String, dynamic>>>(
              stream: firestore
                  .controllerProfileStream(
                user.uid,
              ),
              builder: (context, profileSnapshot) {
                String name =
                    user.displayName ??
                        'Exam Controller';

                if (profileSnapshot.hasData &&
                    profileSnapshot.data!.exists) {
                  final data =
                  profileSnapshot.data!.data();

                  final firestoreName =
                  data?['name']
                      ?.toString()
                      .trim();

                  if (firestoreName != null &&
                      firestoreName.isNotEmpty) {
                    name = firestoreName;
                  }
                }

                return StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream:
                  firestore.controllerNotificationsStream(),

                  builder: (
                      context,
                      notificationSnapshot,
                      ) {
                    int unreadCount = 0;

                    if (notificationSnapshot.hasData) {
                      unreadCount =
                          notificationSnapshot
                              .data!.docs
                              .where(
                                (doc) =>
                            doc.data()['isRead'] !=
                                true,
                          )
                              .length;
                    }

                    return _ControllerHeader(
                      name: name,

                      pendingCount:
                      unreadCount,

                      onNotificationsTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes
                              .controllerNotifications,
                        );
                      },
                    );
                  },
                );
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LiveStatCard(
                            stream: firestore
                                .allStudentsStream(),
                            icon:
                            Icons.school_rounded,
                            label: 'Students',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LiveStatCard(
                            stream: firestore
                                .allTeachersStream(),
                            icon: Icons
                                .menu_book_rounded,
                            label: 'Teachers',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _LiveStatCard(
                            stream: firestore
                                .officialExamsStream(),
                            icon: Icons
                                .assignment_rounded,
                            label:
                            'Official Exams',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LiveStatCard(
                            stream: firestore
                                .officialExamsStream(),
                            icon: Icons
                                .play_circle_fill_rounded,
                            label: 'Active Exams',
                            filter: (doc) {
                              return doc
                                  .data()['status']
                                  ?.toString()
                                  .toLowerCase() ==
                                  'published';
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      title: 'QUICK ACTIONS',
                    ),

                    const SizedBox(height: 10),

                    _ActionTile(
                      icon: Icons
                          .assignment_turned_in_rounded,
                      title:
                      'Manage Official Exams',
                      subtitle:
                      'Review, publish and manage exams',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.officialExams,
                        );
                      },
                    ),

                    const SizedBox(height: 9),

                    StreamBuilder<
                        QuerySnapshot<
                            Map<String, dynamic>>>(
                      stream: firestore
                          .officialExamsStream(),
                      builder: (context, snapshot) {
                        int pending = 0;

                        if (snapshot.hasData) {
                          pending = snapshot
                              .data!.docs
                              .where(
                                (doc) =>
                            doc.data()[
                            'status']
                                ?.toString()
                                .toLowerCase() ==
                                'pending_approval',
                          )
                              .length;
                        }

                        return _ActionTile(
                          icon: Icons
                              .pending_actions_rounded,
                          title:
                          'Pending Approvals',
                          subtitle: pending == 0
                              ? 'No exams waiting for approval'
                              : '$pending exam${pending == 1 ? '' : 's'} waiting',
                          badge: pending > 0
                              ? '$pending'
                              : null,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.officialExams,
                              arguments: {
                                'filter':
                                'pending_approval',
                              },
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 9),

                    _ActionTile(
                      icon:
                      Icons.analytics_rounded,
                      title: 'View Reports',
                      subtitle:
                      'Performance and result analytics',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes
                              .controllerReports,
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      title: 'RECENT ACTIVITY',
                    ),

                    const SizedBox(height: 10),

                    StreamBuilder<
                        QuerySnapshot<
                            Map<String, dynamic>>>(
                      stream: firestore
                          .controllerActivityStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            (snapshot.hasData &&
                                snapshot
                                    .data!.docs.isEmpty)) {
                          return const _EmptyActivity();
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

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                            border: Border.all(
                              color: const Color(
                                0xFFE3E8EF,
                              ),
                            ),
                          ),
                          child: Column(
                            children: snapshot
                                .data!.docs
                                .take(5)
                                .map(
                                  (doc) =>
                                  _ActivityItem(
                                    data: doc.data(),
                                  ),
                            )
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControllerHeader extends StatelessWidget {
  final String name;
  final int pendingCount;
  final VoidCallback onNotificationsTap;

  const _ControllerHeader({
    required this.name,
    required this.pendingCount,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding:
      const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient:
              const LinearGradient(
                colors: [
                  Color(0xFFFFB300),
                  Color(0xFFFF8F00),
                ],
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bano Qabil',
                  style: TextStyle(
                    color:
                    Color(0xFFA9B5C9),
                    fontSize: 9,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: onNotificationsTap,
            borderRadius:
            BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                const Color(0xFF1A2945),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 21,
                  ),

                  if (pendingCount > 0)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        constraints:
                        const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        alignment:
                        Alignment.center,
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        decoration:
                        const BoxDecoration(
                          color:
                          AppColors.controller,
                          shape:
                          BoxShape.circle,
                        ),
                        child: Text(
                          pendingCount > 9
                              ? '9+'
                              : '$pendingCount',
                          style:
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'EC';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}

class _LiveStatCard extends StatelessWidget {
  final Stream<
      QuerySnapshot<
          Map<String, dynamic>>>
  stream;

  final IconData icon;
  final String label;

  final bool Function(
      QueryDocumentSnapshot<
          Map<String, dynamic>> doc,
      )? filter;

  const _LiveStatCard({
    required this.stream,
    required this.icon,
    required this.label,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        String value = '...';

        if (snapshot.hasError) {
          value = '—';
        } else if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          value = filter == null
              ? '${docs.length}'
              : '${docs.where(filter!).length}';
        }

        return _StatCard(
          icon: icon,
          value: value,
          label: label,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color:
          const Color(0xFFE4E9F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.controller
                  .withValues(alpha: 0.11),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 17,
              color:
              AppColors.controller,
            ),
          ),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:
                const TextStyle(
                  fontSize: 21,
                  height: 1,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style:
                const TextStyle(
                  fontSize: 10,
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color:
              const Color(0xFFE3E8EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.controller
                      .withValues(alpha: 0.1),
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color:
                  AppColors.controller,
                  size: 19,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                      const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              if (badge != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors
                        .controller,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    badge!,
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right_rounded,
                color:
                Color(0xFF9CA7B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ActivityItem({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final type =
        data['type']?.toString() ?? '';

    IconData icon =
        Icons.history_rounded;

    Color color =
        AppColors.controller;

    if (type == 'exam_published') {
      icon = Icons.publish_rounded;
      color = Colors.blue;
    } else if (type ==
        'results_released') {
      icon =
          Icons.check_circle_rounded;
      color = Colors.green;
    } else if (type ==
        'attempt_reopened') {
      icon = Icons.refresh_rounded;
      color = Colors.orange;
    } else if (type ==
        'exam_rejected') {
      icon = Icons.cancel_rounded;
      color = Colors.red;
    }

    return Padding(
      padding:
      const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
              color.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data['message']
                  ?.toString() ??
                  'Activity updated',
              style:
              const TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          const Color(0xFFE3E8EF),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 32,
            color:
            Color(0xFF9BA7B8),
          ),
          SizedBox(height: 8),
          Text(
            'No recent activity',
            style: TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color:
        Color(0xFF65728A),
        fontSize: 10,
        letterSpacing: 0.7,
        fontWeight:
        FontWeight.w700,
      ),
    );
  }
}