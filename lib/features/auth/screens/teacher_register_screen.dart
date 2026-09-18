import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../../../services/auth_service.dart';
import '../widgets/register_form.dart';

class TeacherRegisterScreen extends StatelessWidget {
  const TeacherRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return RegisterForm(
      subtitle: 'Join BG Quiz Lab as a teacher.',
      extraFieldLabel: 'Department / Course',
      extraFieldHint: 'Computer Science',
      accentColor: AppColors.teacher,

      // Teacher login route
      loginRoute: AppRoutes.teacherLogin,

      onRegister: (
          name,
          email,
          password,
          extraValue,
          campus,
          ) async {
        await authService.registerTeacher(
          name: name,
          email: email,
          password: password,
          departmentCourse: extraValue,
          campus: campus,
        );
      },
    );
  }
}