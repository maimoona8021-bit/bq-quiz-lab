import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';

import '../widgets/login_form.dart';

class ControllerLoginScreen extends StatelessWidget {
  const ControllerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginForm(
      role: 'controller',
      portalName: 'Exam Controller Portal',
      accentColor: AppColors.controller,
      registerRoute: AppRoutes.controllerRegister,
      dashboardRoute: AppRoutes.controllerDashboard,
    );
  }
}