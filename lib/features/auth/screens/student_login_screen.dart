import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';

import '../../../ core/theme/app_colors.dart';
import '../widgets/login_form.dart';

class StudentLoginScreen extends StatelessWidget {
  const StudentLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginForm(
      role: 'student',
      portalName: 'Student Portal',
      accentColor: AppColors.student,
      registerRoute: AppRoutes.studentRegister,
      dashboardRoute: AppRoutes.studentDashboard,
    );
  }
}