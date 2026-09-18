import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../widgets/login_form.dart';

class TeacherLoginScreen extends StatelessWidget {
  const TeacherLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginForm(
      role: 'teacher',
      portalName: 'Teacher Portal',
      accentColor: AppColors.teacher,
      registerRoute: AppRoutes.teacherRegister,
      dashboardRoute: AppRoutes.teacherDashboard,
    );
  }
}