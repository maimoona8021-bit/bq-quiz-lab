import 'package:flutter/material.dart';

import '../../../ core/ constants/app_constants.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                26,
              ),
              color: AppColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppConstants.logoPath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Choose your role',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'How would you like to continue?',
                    style: TextStyle(
                      color: Color(0xFFB1BED3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _RoleCard(
                      title: 'Student',
                      subtitle:
                      'Take practice quizzes, official exams and track your progress.',
                      color: AppColors.student,
                      icon: Icons.school_outlined,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.studentLogin,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _RoleCard(
                      title: 'Teacher',
                      subtitle:
                      'Create questions, build quizzes and review student attempts.',
                      color: AppColors.teacher,
                      icon: Icons.menu_book_outlined,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.teacherLogin,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _RoleCard(
                      title: 'Exam Controller',
                      subtitle:
                      'Manage official exams, results and examination reports.',
                      color: AppColors.controller,
                      icon: Icons.admin_panel_settings_outlined,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.controllerLogin,
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFFABB6C7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








