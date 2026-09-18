import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../widgets/register_form.dart';

class StudentRegisterScreen extends StatelessWidget {
  const StudentRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return RegisterForm(
      subtitle: 'Join BG Quiz Lab as a student.',
      extraFieldLabel: 'Class / Batch',
      extraFieldHint: 'Batch 14',
      accentColor: AppColors.student,

      // Student login route
      loginRoute: AppRoutes.studentLogin,

      onRegister: (
          name,
          email,
          password,
          extraValue,
          campus,
          ) async {
        await authService.registerStudent(
          name: name,
          email: email,
          password: password,
          classBatch: extraValue,
          campus: campus,
        );
      },
    );
  }
}