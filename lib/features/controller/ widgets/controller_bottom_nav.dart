import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../ core/theme/app_colors.dart';



class ControllerBottomNav extends StatelessWidget {
  final int currentIndex;

  const ControllerBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    final routes = [
      AppRoutes.controllerDashboard,
      AppRoutes.officialExams,
      AppRoutes.controllerReports,
      AppRoutes.controllerProfile,
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
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
      ),
      _NavItem(
        label: 'Exams',
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded,
      ),
      _NavItem(
        label: 'Reports',
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
        height: 72,
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
          children: List.generate(
            items.length,
                (index) {
              final selected = currentIndex == index;
              final item = items[index];

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
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        width: selected ? 42 : 34,
                        height: selected ? 35 : 30,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.controller
                              .withValues(alpha: 0.14)
                              : Colors.transparent,
                          borderRadius:
                          BorderRadius.circular(11),
                        ),
                        child: AnimatedScale(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          scale: selected ? 1.13 : 1,
                          child: Icon(
                            selected
                                ? item.activeIcon
                                : item.icon,
                            size: selected ? 21 : 19,
                            color: selected
                                ? AppColors.controller
                                : const Color(0xFF7D899C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 8.5,
                          color: selected
                              ? AppColors.controller
                              : const Color(0xFF7D899C),
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
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