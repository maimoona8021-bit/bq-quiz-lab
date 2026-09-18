import 'package:flutter/material.dart';

import '../../../ core/ routes/app_routes.dart';
import '../../../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();

  bool _checking = false;
  bool _resending = false;

  Future<void> _checkVerification() async {
    setState(() {
      _checking = true;
    });

    try {
      final verified =
      await _authService.checkEmailVerification();

      if (!mounted) return;

      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email is not verified yet.',
            ),
          ),
        );
        return;
      }

      final role =
      await _authService.getCurrentRole();

      if (!mounted) return;

      final route =
      AppRoutes.dashboardForRole(role);

      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
            (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
    });

    try {
      await _authService.resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent again.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _resending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        _authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 75,
                  color: Color(0xFF2F6BF3),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We sent a verification link to\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                    _checking
                        ? null
                        : _checkVerification,
                    child: _checking
                        ? const CircularProgressIndicator()
                        : const Text(
                      "I've Verified My Email",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed:
                  _resending ? null : _resend,
                  child: Text(
                    _resending
                        ? 'Sending...'
                        : 'Resend verification email',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}