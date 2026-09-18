import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';


class TeacherBottomNav extends StatelessWidget {
  final int currentIndex;

  const TeacherBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _goTo(
      BuildContext context,
      int index,
      ) {
    if (index == currentIndex) return;

    final routes = [
      AppRoutes.teacherDashboard,
      AppRoutes.questionBank,
      AppRoutes.myQuizzes,
      AppRoutes.teacherAttempts,
      AppRoutes.teacherProfile,
    ];

    Navigator.pushReplacementNamed(
      context,
      routes[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _NavItem(
        label: 'Questions',
        icon: Icons.quiz_outlined,
        activeIcon: Icons.quiz_rounded,
      ),
      _NavItem(
        label: 'Quizzes',
        icon: Icons.layers_outlined,
        activeIcon: Icons.layers_rounded,
      ),
      _NavItem(
        label: 'Attempts',
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
      ),
      _NavItem(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE7EBF1),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children:
          List.generate(items.length, (index) {
            final bool selected =
                currentIndex == index;

            final item = items[index];

            return Expanded(
              child: InkWell(
                onTap: () =>
                    _goTo(context, index),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      curve: Curves.easeOut,
                      width: selected ? 39 : 32,
                      height: selected ? 34 : 30,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.teacher
                            .withValues(
                          alpha: 0.12,
                        )
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(
                          11,
                        ),
                      ),
                      child: AnimatedScale(
                        scale:
                        selected ? 1.13 : 1,
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        child: Icon(
                          selected
                              ? item.activeIcon
                              : item.icon,
                          color: selected
                              ? AppColors.teacher
                              : const Color(
                            0xFF7E8A9E,
                          ),
                          size:
                          selected ? 20 : 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? AppColors.teacher
                            : const Color(
                          0xFF7E8A9E,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}