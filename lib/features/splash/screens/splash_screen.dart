import 'package:flutter/material.dart';

import '../../../ core/ constants/app_constants.dart';
import '../../../ core/ routes/app_routes.dart';
import '../../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  final AuthService _authService =
  AuthService();

  @override
  void initState() {
    super.initState();

    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Keep splash visible
    await Future.delayed(
      const Duration(
        seconds: 3,
      ),
    );

    if (!mounted) {
      return;
    }

    try {
      // Firebase restores previous login.
      // AuthService also reconnects OneSignal.
      final user =
      await _authService
          .getRestoredUser();

      if (!mounted) {
        return;
      }

      // =====================================================
      // NO USER LOGGED IN
      // =====================================================

      if (user == null) {
        _goTo(
          AppRoutes.roleSelection,
        );
        return;
      }

      // =====================================================
      // EMAIL NOT VERIFIED
      // =====================================================

      if (!user.emailVerified) {
        _goTo(
          AppRoutes.emailVerification,
        );
        return;
      }

      // =====================================================
      // GET SAVED ROLE
      // =====================================================

      final role =
      await _authService
          .getCurrentRole();

      if (!mounted) {
        return;
      }

      // =====================================================
      // GO TO CORRECT DASHBOARD
      // =====================================================

      switch (role) {
        case 'student':
          _goTo(
            AppRoutes.studentDashboard,
          );
          break;

        case 'teacher':
          _goTo(
            AppRoutes.teacherDashboard,
          );
          break;

        case 'controller':
          _goTo(
            AppRoutes.controllerDashboard,
          );
          break;

        default:
        // Profile missing or invalid role.
          await _authService.signOut();

          if (!mounted) {
            return;
          }

          _goTo(
            AppRoutes.roleSelection,
          );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      // If something goes wrong,
      // safely return to role selection.
      _goTo(
        AppRoutes.roleSelection,
      );
    }
  }

  void _goTo(
      String route,
      ) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
          (_) => false,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFF09152D,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            // =================================================
            // CENTER
            // =================================================

            Center(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Image.asset(
                    AppConstants.logoPath,
                    width: 100,
                    height: 100,
                    fit:
                    BoxFit.contain,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    'BQ Quiz Lab',
                    style:
                    TextStyle(
                      color:
                      Colors.white,
                      fontSize:
                      24,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    'Quiz App',
                    style:
                    TextStyle(
                      color:
                      Color(
                        0xFF9AA6BD,
                      ),
                      fontSize:
                      13,
                      fontWeight:
                      FontWeight.w400,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const Text(
                    'Built for Excellence',
                    style:
                    TextStyle(
                      color:
                      Color(
                        0xFF65738E,
                      ),
                      fontSize:
                      11,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // BOTTOM TEXT
            // =================================================

            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Text(
                'LEARN  •  PRACTICE  •  ACHIEVE',
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  color:
                  Color(
                    0xFF65738E,
                  ),
                  fontSize:
                  9,
                  fontWeight:
                  FontWeight.w500,
                  letterSpacing:
                  1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}