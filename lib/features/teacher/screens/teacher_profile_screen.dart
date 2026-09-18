import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../widgets/teacher_bottom_nav.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({
    super.key,
  });

  @override
  State<TeacherProfileScreen> createState() =>
      _TeacherProfileScreenState();
}

class _TeacherProfileScreenState
    extends State<TeacherProfileScreen> {
  final FirestoreService _firestore =
  FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Teacher not logged in.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,

      bottomNavigationBar:
      const TeacherBottomNav(
        currentIndex: 4,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ===================================================
            // HEADER
            // ===================================================

            Container(
              width:
              double.infinity,
              color:
              AppColors.navy,
              padding:
              const EdgeInsets.fromLTRB(
                18,
                17,
                18,
                17,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                    BoxDecoration(
                      color: AppColors
                          .teacher
                          .withValues(
                        alpha: 0.16,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        11,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .person_rounded,
                      color:
                      AppColors.teacher,
                      size: 20,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'Profile',
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      SizedBox(
                        height: 2,
                      ),

                      Text(
                        'Manage your teacher profile',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF9FAAC0,
                          ),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===================================================
            // PROFILE
            // ===================================================

            Expanded(
              child: StreamBuilder<
                  DocumentSnapshot<
                      Map<String, dynamic>>>(
                stream: _firestore
                    .teacherProfileStream(
                  user.uid,
                ),
                builder:
                    (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load profile.',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        AppColors.teacher,
                      ),
                    );
                  }

                  final data =
                      snapshot.data!
                          .data() ??
                          {};

                  final String name =
                      data['name']
                          ?.toString() ??
                          user.displayName ??
                          'Teacher';

                  final String email =
                      data['email']
                          ?.toString() ??
                          user.email ??
                          '';

                  final String department =
                      data[
                      'departmentCourse']
                          ?.toString() ??
                          '';

                  final String campus =
                      data['campus']
                          ?.toString() ??
                          '';

                  return ListView(
                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      30,
                    ),
                    children: [
                      // ===========================================
                      // PROFILE CARD
                      // ===========================================

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
                          BorderRadius.circular(
                            18,
                          ),
                          border:
                          Border.all(
                            color:
                            const Color(
                              0xFFE4EAF1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black
                                  .withValues(
                                alpha:
                                0.035,
                              ),
                              blurRadius:
                              12,
                              offset:
                              const Offset(
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // AVATAR

                            Container(
                              width: 82,
                              height: 82,
                              alignment:
                              Alignment.center,
                              decoration:
                              BoxDecoration(
                                color:
                                AppColors
                                    .teacher,
                                shape:
                                BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    AppColors
                                        .teacher
                                        .withValues(
                                      alpha:
                                      0.20,
                                    ),
                                    blurRadius:
                                    18,
                                    offset:
                                    const Offset(
                                      0,
                                      7,
                                    ),
                                  ),
                                ],
                              ),
                              child: Text(
                                name.isEmpty
                                    ? 'T'
                                    : name[0]
                                    .toUpperCase(),
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize:
                                  29,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 13,
                            ),

                            Text(
                              name,
                              textAlign:
                              TextAlign.center,
                              style:
                              const TextStyle(
                                color:
                                AppColors
                                    .textPrimary,
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              email,
                              textAlign:
                              TextAlign.center,
                              style:
                              const TextStyle(
                                color:
                                AppColors
                                    .textSecondary,
                                fontSize: 9,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration:
                              BoxDecoration(
                                color:
                                AppColors
                                    .teacher
                                    .withValues(
                                  alpha:
                                  0.09,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                              child:
                              const Text(
                                'TEACHER',
                                style:
                                TextStyle(
                                  color:
                                  AppColors
                                      .teacher,
                                  fontSize:
                                  8,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 17,
                            ),

                            SizedBox(
                              width:
                              double.infinity,
                              child:
                              ElevatedButton.icon(
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  AppColors
                                      .teacher,
                                  foregroundColor:
                                  Colors.white,
                                  elevation:
                                  0,
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical:
                                    13,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      11,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _showEditProfile(
                                    user:
                                    user,
                                    name:
                                    name,
                                    department:
                                    department,
                                    campus:
                                    campus,
                                  );
                                },
                                icon:
                                const Icon(
                                  Icons
                                      .edit_rounded,
                                  size:
                                  17,
                                ),
                                label:
                                const Text(
                                  'Edit Profile',
                                  style:
                                  TextStyle(
                                    fontSize:
                                    10,
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ===========================================
                      // INFORMATION
                      // ===========================================

                      const _SectionTitle(
                        title:
                        'ACCOUNT INFORMATION',
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      _info(
                        icon:
                        Icons
                            .menu_book_rounded,
                        label:
                        'Department / Course',
                        value:
                        department.isEmpty
                            ? 'Not provided'
                            : department,
                        color:
                        AppColors.teacher,
                      ),

                      _info(
                        icon:
                        Icons
                            .location_city_rounded,
                        label:
                        'Campus',
                        value:
                        campus.isEmpty
                            ? 'Not provided'
                            : campus,
                        color:
                        const Color(
                          0xFF5066C8,
                        ),
                      ),

                      _info(
                        icon:
                        Icons
                            .email_outlined,
                        label:
                        'Email',
                        value:
                        email,
                        color:
                        const Color(
                          0xFF7558D8,
                        ),
                      ),

                      _info(
                        icon:
                        Icons
                            .verified_user_rounded,
                        label:
                        'Email Status',
                        value:
                        user.emailVerified
                            ? 'Verified'
                            : 'Not verified',
                        color:
                        user.emailVerified
                            ? const Color(
                          0xFF159A61,
                        )
                            : Colors.orange,
                      ),

                      const SizedBox(
                        height: 17,
                      ),

                      // ===========================================
                      // SECURITY
                      // ===========================================

                      const _SectionTitle(
                        title:
                        'SECURITY',
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      _actionTile(
                        icon:
                        Icons
                            .lock_outline_rounded,
                        title:
                        'Change Password',
                        subtitle:
                        'Send a password reset email',
                        color:
                        AppColors.teacher,
                        onTap:
                            () async {
                          if (user.email ==
                              null) {
                            return;
                          }

                          await FirebaseAuth
                              .instance
                              .sendPasswordResetEmail(
                            email:
                            user.email!,
                          );

                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content:
                              Text(
                                'Password reset email sent.',
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      _actionTile(
                        icon:
                        Icons
                            .logout_rounded,
                        title:
                        'Sign Out',
                        subtitle:
                        'Sign out of this account',
                        color:
                        Colors.red,
                        onTap:
                            () async {
                          await AuthService()
                              .signOut();

                          if (!mounted) {
                            return;
                          }

                          Navigator
                              .pushNamedAndRemoveUntil(
                            context,
                            AppRoutes
                                .roleSelection,
                                (_) =>
                            false,
                          );
                        },
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

  // ==============================================================
  // EDIT PROFILE DIALOG
  // ==============================================================

  Future<void> _showEditProfile({
    required User user,
    required String name,
    required String department,
    required String campus,
  }) async {
    final nameController =
    TextEditingController(
      text:
      name,
    );

    final departmentController =
    TextEditingController(
      text:
      department,
    );

    final campusController =
    TextEditingController(
      text:
      campus,
    );

    final formKey =
    GlobalKey<FormState>();

    bool saving =
    false;

    await showDialog<void>(
      context:
      context,
      barrierDismissible:
      false,
      builder:
          (dialogContext) {
        return StatefulBuilder(
          builder:
              (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              title:
              const Row(
                children: [
                  Icon(
                    Icons
                        .edit_rounded,
                    color:
                    AppColors.teacher,
                  ),

                  SizedBox(
                    width: 8,
                  ),

                  Text(
                    'Edit Profile',
                  ),
                ],
              ),

              content:
              Form(
                key:
                formKey,
                child:
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      // NAME

                      TextFormField(
                        controller:
                        nameController,
                        textCapitalization:
                        TextCapitalization
                            .words,
                        decoration:
                        _inputDecoration(
                          label:
                          'Full Name',
                          icon:
                          Icons
                              .person_outline_rounded,
                        ),
                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .length <
                                  2) {
                            return 'Enter a valid name.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // DEPARTMENT

                      TextFormField(
                        controller:
                        departmentController,
                        decoration:
                        _inputDecoration(
                          label:
                          'Department / Course',
                          icon:
                          Icons
                              .menu_book_rounded,
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // CAMPUS

                      TextFormField(
                        controller:
                        campusController,
                        decoration:
                        _inputDecoration(
                          label:
                          'Campus',
                          icon:
                          Icons
                              .location_city_rounded,
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // EMAIL READ ONLY

                      TextFormField(
                        initialValue:
                        user.email ??
                            '',
                        enabled:
                        false,
                        decoration:
                        _inputDecoration(
                          label:
                          'Email',
                          icon:
                          Icons
                              .email_outlined,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      const Align(
                        alignment:
                        Alignment.centerLeft,
                        child:
                        Text(
                          'Email cannot be changed here.',
                          style:
                          TextStyle(
                            color:
                            AppColors
                                .textSecondary,
                            fontSize:
                            8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed:
                  saving
                      ? null
                      : () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    AppColors.teacher,
                    foregroundColor:
                    Colors.white,
                    elevation:
                    0,
                  ),
                  onPressed:
                  saving
                      ? null
                      : () async {
                    if (!(formKey
                        .currentState
                        ?.validate() ??
                        false)) {
                      return;
                    }

                    setDialogState(
                          () {
                        saving =
                        true;
                      },
                    );

                    try {
                      final newName =
                      nameController.text
                          .trim();

                      await _firestore
                          .updateTeacherProfile(
                        teacherId:
                        user.uid,
                        name:
                        newName,
                        departmentCourse:
                        departmentController
                            .text
                            .trim(),
                        campus:
                        campusController
                            .text
                            .trim(),
                      );

                      // Also update Firebase display name.
                      await user
                          .updateDisplayName(
                        newName,
                      );

                      if (!mounted) {
                        return;
                      }

                      if (dialogContext
                          .mounted) {
                        Navigator.pop(
                          dialogContext,
                        );
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                          Text(
                            'Profile updated successfully.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      setDialogState(
                            () {
                          saving =
                          false;
                        },
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                          Text(
                            'Unable to update profile: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child:
                  saving
                      ? const SizedBox(
                    width:
                    17,
                    height:
                    17,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    departmentController.dispose();
    campusController.dispose();
  }

  // ==============================================================
  // INPUT DECORATION
  // ==============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText:
      label,
      prefixIcon:
      Icon(
        icon,
        color:
        AppColors.teacher,
        size:
        19,
      ),
      filled:
      true,
      fillColor:
      const Color(
        0xFFF7F9FC,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          12,
        ),
        borderSide:
        const BorderSide(
          color:
          Color(
            0xFFE2E8F0,
          ),
        ),
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          12,
        ),
        borderSide:
        const BorderSide(
          color:
          Color(
            0xFFE2E8F0,
          ),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          12,
        ),
        borderSide:
        const BorderSide(
          color:
          AppColors.teacher,
          width:
          1.4,
        ),
      ),
    );
  }

  // ==============================================================
  // INFO CARD
  // ==============================================================

  Widget _info({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 9,
      ),
      padding:
      const EdgeInsets.all(
        13,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          13,
        ),
        border:
        Border.all(
          color:
          const Color(
            0xFFE5EAF0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration:
            BoxDecoration(
              color:
              color.withValues(
                alpha:
                0.09,
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color:
              color,
              size:
              19,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .textSecondary,
                    fontSize:
                    8,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                  const TextStyle(
                    color:
                    AppColors
                        .textPrimary,
                    fontSize:
                    10,
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

  // ==============================================================
  // ACTION TILE
  // ==============================================================

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
      onTap,
      borderRadius:
      BorderRadius.circular(
        13,
      ),
      child: Container(
        padding:
        const EdgeInsets.all(
          13,
        ),
        decoration:
        BoxDecoration(
          color:
          Colors.white,
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          border:
          Border.all(
            color:
            const Color(
              0xFFE5EAF0,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration:
              BoxDecoration(
                color:
                color.withValues(
                  alpha:
                  0.09,
                ),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                icon,
                color:
                color,
                size:
                19,
              ),
            ),

            const SizedBox(
              width: 11,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                    TextStyle(
                      color:
                      color ==
                          Colors.red
                          ? Colors.red
                          : AppColors
                          .textPrimary,
                      fontSize:
                      10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    subtitle,
                    style:
                    const TextStyle(
                      color:
                      AppColors
                          .textSecondary,
                      fontSize:
                      8,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons
                  .chevron_right_rounded,
              color:
              color ==
                  Colors.red
                  ? Colors.red
                  : const Color(
                0xFF9AA6B7,
              ),
              size:
              18,
            ),
          ],
        ),
      ),
    );
  }
}


// ================================================================
// SECTION TITLE
// ================================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
      const TextStyle(
        color:
        AppColors.textSecondary,
        fontSize:
        9,
        fontWeight:
        FontWeight.w800,
        letterSpacing:
        0.6,
      ),
    );
  }
}