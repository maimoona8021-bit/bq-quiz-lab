import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';



class StudentBottomNav extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _navigate(
      BuildContext context,
      int index,
      ) {
    if (index == currentIndex) return;

    final routes = [
      AppRoutes.studentDashboard,
      AppRoutes.studentExams,
      AppRoutes.attemptHistory,
      AppRoutes.studentProfile,
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
        label: 'Exams',
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
      ),
      _NavItem(
        label: 'Results',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
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
              color: Color(0xFFE5EAF1),
            ),
          ),
        ),
        child: Row(
          children: List.generate(
            items.length,
                (index) {
              final selected =
                  index == currentIndex;

              final item =
              items[index];

              return Expanded(
                child: InkWell(
                  onTap: () => _navigate(
                    context,
                    index,
                  ),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        duration:
                        const Duration(
                          milliseconds: 180,
                        ),
                        scale:
                        selected ? 1.12 : 1,
                        child: Icon(
                          selected
                              ? item.activeIcon
                              : item.icon,
                          color: selected
                              ? AppColors.student
                              : const Color(
                            0xFF7C899D,
                          ),
                          size: 21,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.student
                              : const Color(
                            0xFF7C899D,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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