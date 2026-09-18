import 'package:flutter/material.dart';


import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../widgets/register_form.dart';

class ControllerRegisterScreen extends StatelessWidget {
  const ControllerRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return RegisterForm(
      subtitle: 'Join BG Quiz Lab as an exam controller.',
      extraFieldLabel: 'Campus Role / Designation',
      extraFieldHint: 'Deputy Exam Controller',
      accentColor: AppColors.controller,

      // Controller login route
      loginRoute: AppRoutes.controllerLogin,

      onRegister: (
          name,
          email,
          password,
          extraValue,
          campus,
          ) async {
        await authService.registerController(
          name: name,
          email: email,
          password: password,
          designation: extraValue,
          campus: campus,
        );
      },
    );
  }
}