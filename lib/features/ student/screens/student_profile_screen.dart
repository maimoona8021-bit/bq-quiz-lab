import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../ widgets/student_bottom_nav.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

class StudentProfileScreen
    extends StatelessWidget {
  const StudentProfileScreen({
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

      bottomNavigationBar:
      const StudentBottomNav(
        currentIndex: 3,
      ),

      appBar: AppBar(
        backgroundColor:
        AppColors.navy,
        foregroundColor:
        Colors.white,
        title:
        const Text(
          'Profile',
        ),
      ),

      body: StreamBuilder(
        stream: firestore
            .studentProfileStream(
          user.uid,
        ),
        builder:
            (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!
                  .data() ??
                  {};

          final name =
              data['name']
                  ?.toString() ??
                  'Student';

          return ListView(
            padding:
            const EdgeInsets.all(
              16,
            ),
            children: [
              Container(
                padding:
                const EdgeInsets.all(
                  20,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.white,
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor:
                      AppColors
                          .student,
                      child: Text(
                        name.isEmpty
                            ? 'S'
                            : name[0]
                            .toUpperCase(),
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize: 25,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      name,
                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    Text(
                      user.email ?? '',
                      style:
                      const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 9,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '${data['classBatch'] ?? ''} • ${data['campus'] ?? ''}',
                      style:
                      const TextStyle(
                        color: AppColors
                            .student,
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.student,
                          foregroundColor:
                          Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes
                                .editStudentProfile,
                            arguments: {
                              'name': name,
                              'classBatch':
                              data['classBatch']
                                  ?.toString() ??
                                  '',
                              'campus':
                              data['campus']
                                  ?.toString() ??
                                  '',
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 17,
                        ),
                        label:
                        const Text(
                          'Edit Profile',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              _tile(
                Icons
                    .notifications_none,
                'Notifications',
                    () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes
                        .studentNotifications,
                  );
                },
              ),

              _tile(
                Icons.lock_outline,
                'Change Password',
                    () async {
                  if (user.email !=
                      null) {
                    await FirebaseAuth
                        .instance
                        .sendPasswordResetEmail(
                      email:
                      user.email!,
                    );

                    if (!context
                        .mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent.',
                        ),
                      ),
                    );
                  }
                },
              ),

              _tile(
                Icons.logout,
                'Logout',
                    () async {
                  await AuthService()
                      .signOut();

                  if (!context
                      .mounted) {
                    return;
                  }

                  Navigator
                      .pushNamedAndRemoveUntil(
                    context,
                    AppRoutes
                        .roleSelection,
                        (_) => false,
                  );
                },
                red: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool red = false,
      }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 9,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: red
              ? Colors.red
              : AppColors.student,
        ),
        title: Text(
          title,
          style:
          TextStyle(
            fontSize: 10,
            color: red
                ? Colors.red
                : AppColors
                .textPrimary,
            fontWeight:
            FontWeight.w600,
          ),
        ),
        trailing:
        const Icon(
          Icons
              .chevron_right_rounded,
        ),
      ),
    );
  }
}