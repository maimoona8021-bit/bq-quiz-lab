import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class EditStudentProfileScreen
    extends StatefulWidget {
  final String currentName;
  final String classBatch;
  final String campus;

  const EditStudentProfileScreen({
    super.key,
    required this.currentName,
    required this.classBatch,
    required this.campus,
  });

  @override
  State<EditStudentProfileScreen>
  createState() =>
      _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState
    extends State<EditStudentProfileScreen> {
  late final TextEditingController
  _nameController;

  final FirestoreService _firestore =
  FirestoreService();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
          text: widget.currentName,
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final name =
    _nameController.text.trim();

    if (name.length < 2) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid name.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore
          .updateStudentProfile(
        studentId: user.uid,
        name: name,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update profile: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Edit Profile',
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(
          18,
        ),
        children: [
          Center(
            child: Container(
              width: 92,
              height: 92,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                gradient:
                const LinearGradient(
                  colors: [
                    Color(
                      0xFF2F6BF3,
                    ),
                    Color(
                      0xFF78A1FF,
                    ),
                  ],
                ),
                shape:
                BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors
                        .student
                        .withValues(
                      alpha: 0.22,
                    ),
                    blurRadius: 18,
                    offset:
                    const Offset(
                      0,
                      7,
                    ),
                  ),
                ],
              ),
              child: Text(
                widget.currentName
                    .isEmpty
                    ? 'S'
                    : widget
                    .currentName[0]
                    .toUpperCase(),
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 31,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          TextField(
            controller:
            _nameController,
            textCapitalization:
            TextCapitalization.words,
            decoration:
            InputDecoration(
              labelText:
              'Full Name',
              prefixIcon:
              const Icon(
                Icons
                    .person_rounded,
                color:
                AppColors.student,
              ),
              filled: true,
              fillColor:
              Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          _ReadOnlyField(
            icon:
            Icons.groups_2_rounded,
            label: 'Batch',
            value:
            widget.classBatch,
          ),

          const SizedBox(
            height: 12,
          ),

          _ReadOnlyField(
            icon:
            Icons.location_on_rounded,
            label: 'Campus',
            value:
            widget.campus,
          ),

          const SizedBox(
            height: 8,
          ),

          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 15,
                color: AppColors
                    .textSecondary,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Batch and campus are assigned by the administration and cannot be changed here.',
                  style:
                  TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 30,
          ),

          SizedBox(
            height: 52,
            child:
            ElevatedButton.icon(
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                AppColors.student,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              onPressed:
              _saving
                  ? null
                  : _save,
              icon: _saving
                  ? const SizedBox(
                width: 17,
                height: 17,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                  color:
                  Colors.white,
                ),
              )
                  : const Icon(
                Icons
                    .check_circle_rounded,
              ),
              label: Text(
                _saving
                    ? 'Saving...'
                    : 'Save Changes',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color: const Color(
          0xFFF1F4F8,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color: AppColors
                  .student
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              icon,
              color:
              AppColors.student,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                const TextStyle(
                  fontSize: 8,
                  color: AppColors
                      .textSecondary,
                ),
              ),
              Text(
                value.isEmpty
                    ? 'Not provided'
                    : value,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const Spacer(),

          const Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color:
            AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}