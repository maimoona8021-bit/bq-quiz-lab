import 'package:flutter/material.dart';

import '../../features/ student/screens/answer_review_screen.dart';
import '../../features/ student/screens/attempt_history_screen.dart';
import '../../features/ student/screens/edit_student_profile_screen.dart';
import '../../features/ student/screens/exam_rules_screen.dart';
import '../../features/ student/screens/official_result_waiting_screen.dart';
import '../../features/ student/screens/practice_leaderboard_screen.dart';
import '../../features/ student/screens/quiz_player_screen.dart';
import '../../features/ student/screens/result_screen.dart';
import '../../features/ student/screens/student_dashboard_screen.dart';
import '../../features/ student/screens/student_exams_screen.dart';
import '../../features/ student/screens/student_notifications_screen.dart';
import '../../features/ student/screens/student_profile_screen.dart';
import '../../features/ student/screens/weak_topics_screen.dart';
import '../../features/auth/screens/controller_login_screen.dart';
import '../../features/auth/screens/controller_register_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/auth/screens/student_login_screen.dart';
import '../../features/auth/screens/student_register_screen.dart';
import '../../features/auth/screens/teacher_login_screen.dart';
import '../../features/auth/screens/teacher_register_screen.dart';

import '../../features/controller/screens/controller_dashboard_screen.dart';
import '../../features/controller/screens/controller_notifications_screen.dart';
import '../../features/controller/screens/controller_profile_screen.dart';
import '../../features/controller/screens/controller_reports_screen.dart';
import '../../features/controller/screens/exam_management_screen.dart';
import '../../features/controller/screens/official_exams_screen.dart';
import '../../features/controller/screens/reopen_attempt_screen.dart';
import '../../features/role_selection/ screens/role_selection_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/teacher/screens/add_edit_question_screen.dart';
import '../../features/teacher/screens/create_quiz_screen.dart';
import '../../features/teacher/screens/my_quizzes_screen.dart';
import '../../features/teacher/screens/question_bank_screen.dart';
import '../../features/teacher/screens/student_attempts_screen.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  // =========================================================
  // ROUTE NAMES
  // =========================================================

  // Splash
  static const String splash = '/';

  // Role Selection
  static const String roleSelection = '/role-selection';
  static const String studentDashboard =
      '/student-dashboard';

  static const String studentExams =
      '/student-exams';

  static const String examRules =
      '/student-exam-rules';

  static const String quizPlayer =
      '/student-quiz-player';

  static const String result =
      '/student-result';

  static const String officialResultWaiting =
      '/student-official-result-waiting';

  static const String answerReview =
      '/student-answer-review';

  static const String attemptHistory =
      '/student-attempt-history';

  static const String practiceLeaderboard =
      '/student-practice-leaderboard';

  static const String weakTopics =
      '/student-weak-topics';

  static const String studentNotifications =
      '/student-notifications';

  static const String studentProfile =
      '/student-profile';
  // Registration
  static const String studentRegister = '/student-register';
  static const String teacherRegister = '/teacher-register';
  static const String controllerRegister = '/controller-register';

  // Login
  static const String studentLogin = '/student-login';
  static const String teacherLogin = '/teacher-login';
  static const String controllerLogin = '/controller-login';
// =========================================================
// TEACHER
// =========================================================

  static const String questionBank = '/question-bank';

  static const String addQuestion = '/add-question';

  static const String editQuestion = '/edit-question';

  static const String createQuiz = '/create-quiz';

  static const String officialExams =
      '/controller-official-exams';

  static const String controllerReports =
      '/controller-reports';

  static const String controllerProfile =
      '/controller-profile';


  static const String examManagement =
      '/controller-exam-management';

  static const String reopenAttempt =
      '/controller-reopen-attempt';


  static const String editStudentProfile = '/student-edit-profile';

  static const String myQuizzes =
      '/teacher-my-quizzes';

  static const String teacherAttempts = '/teacher-attempts';
  static const String controllerNotifications =
      '/controller-notifications';
  static const String teacherProfile = '/teacher-profile';
  // Email Verification
  static const String emailVerification = '/email-verification';

  // Dashboards
  static const String teacherDashboard = '/teacher-dashboard';
  static const String controllerDashboard = '/controller-dashboard';

  // =========================================================
  // ROLE → DASHBOARD
  // =========================================================

  static String dashboardForRole(String? role) {
    switch (role) {
      case 'student':
        return studentDashboard;

      case 'teacher':
        return teacherDashboard;

      case 'controller':
        return controllerDashboard;

      default:
        return roleSelection;
    }
  }

  // =========================================================
  // ROUTE GENERATOR
  // =========================================================

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Splash
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

    // Role Selection
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );

    // =====================================================
    // REGISTER
    // =====================================================

      case studentRegister:
        return MaterialPageRoute(
          builder: (_) => const StudentRegisterScreen(),
          settings: settings,
        );

      case teacherRegister:
        return MaterialPageRoute(
          builder: (_) => const TeacherRegisterScreen(),
          settings: settings,
        );

      case controllerRegister:
        return MaterialPageRoute(
          builder: (_) => const ControllerRegisterScreen(),
          settings: settings,
        );
      case controllerNotifications:
        return MaterialPageRoute(
          builder: (_) =>
          const ControllerNotificationsScreen(),
          settings: settings,
        );
    // =====================================================
    // LOGIN
    // =====================================================
      case officialExams:
        final args =
        settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => OfficialExamsScreen(
            initialFilter:
            args?['filter'] as String? ?? 'all',
          ),
          settings: settings,
        );
      case editStudentProfile:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => EditStudentProfileScreen(
            currentName: args['name'] as String,
            classBatch: args['classBatch'] as String? ?? '',
            campus: args['campus'] as String? ?? '',
          ),
          settings: settings,
        );
      case examManagement:
        final quizId =
        settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => ExamManagementScreen(
            quizId: quizId,
          ),
          settings: settings,
        );

      case reopenAttempt:
        final args =
        settings.arguments
        as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => ReopenAttemptScreen(
            attemptId:
            args['attemptId'] as String,
            studentName:
            args['studentName'] as String,
            quizTitle:
            args['quizTitle'] as String,
            currentStatus:
            args['currentStatus'] as String,
          ),
          settings: settings,
        );

      case controllerReports:
        String? quizId;

        if (settings.arguments is String) {
          quizId =
          settings.arguments as String;
        }

        return MaterialPageRoute(
          builder: (_) =>
              ControllerReportsScreen(
                initialQuizId: quizId,
              ),
          settings: settings,
        );
      case studentDashboard:
        return MaterialPageRoute(
          builder: (_) =>
          const StudentDashboardScreen(),
          settings: settings,
        );

      case studentExams:
        final args =
        settings.arguments
        as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) =>
              StudentExamsScreen(
                initialSubject:
                args?['subject']
                as String?,
              ),
          settings: settings,
        );

      case examRules:
        return MaterialPageRoute(
          builder: (_) =>
              ExamRulesScreen(
                quizId:
                settings.arguments
                as String,
              ),
          settings: settings,
        );

      case quizPlayer:
        final args =
        settings.arguments
        as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) =>
              QuizPlayerScreen(
                quizId:
                args['quizId']
                as String,
                attemptId:
                args['attemptId']
                as String,
              ),
          settings: settings,
        );

      case result:
        final args =
        settings.arguments
        as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) =>
              ResultScreen(
                attemptId:
                args['attemptId']
                as String,
                quizId:
                args['quizId']
                as String,
              ),
          settings: settings,
        );

      case officialResultWaiting:
        final args =
        settings.arguments
        as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) =>
              OfficialResultWaitingScreen(
                attemptId:
                args['attemptId']
                as String,
                quizId:
                args['quizId']
                as String,
              ),
          settings: settings,
        );

      case answerReview:
        final args =
        settings.arguments
        as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) =>
              AnswerReviewScreen(
                attemptId:
                args['attemptId']
                as String,
                quizId:
                args['quizId']
                as String,
              ),
          settings: settings,
        );

      case attemptHistory:
        return MaterialPageRoute(
          builder: (_) =>
          const AttemptHistoryScreen(),
          settings: settings,
        );

      case practiceLeaderboard:
        String? quizId;

        if (settings.arguments
        is String) {
          quizId =
          settings.arguments
          as String;
        }

        return MaterialPageRoute(
          builder: (_) =>
              PracticeLeaderboardScreen(
                quizId: quizId,
              ),
          settings: settings,
        );

      case weakTopics:
        return MaterialPageRoute(
          builder: (_) =>
          const WeakTopicsScreen(),
          settings: settings,
        );

      case studentNotifications:
        return MaterialPageRoute(
          builder: (_) =>
          const StudentNotificationsScreen(),
          settings: settings,
        );

      case studentProfile:
        return MaterialPageRoute(
          builder: (_) =>
          const StudentProfileScreen(),
          settings: settings,
        );
      case studentProfile:
        return MaterialPageRoute(
          builder: (_) =>
          const StudentProfileScreen(),
          settings: settings,
        );
      case controllerProfile:
        return MaterialPageRoute(
          builder: (_) =>
          const ControllerProfileScreen(),
          settings: settings,
        );
      case studentLogin:
        return MaterialPageRoute(
          builder: (_) => const StudentLoginScreen(),
          settings: settings,
        );

      case teacherLogin:
        return MaterialPageRoute(
          builder: (_) => const TeacherLoginScreen(),
          settings: settings,
        );

      case controllerLogin:
        return MaterialPageRoute(
          builder: (_) => const ControllerLoginScreen(),
          settings: settings,
        );

    // =====================================================
    // EMAIL VERIFICATION
    // =====================================================

      case emailVerification:
        return MaterialPageRoute(
          builder: (_) => const EmailVerificationScreen(),
          settings: settings,
        );

    // =====================================================
    // DASHBOARDS
    // =====================================================

      case studentDashboard:
        return MaterialPageRoute(
          builder: (_) => const StudentDashboardScreen(),
          settings: settings,
        );

      case teacherDashboard:
        return MaterialPageRoute(
          builder: (_) => const TeacherDashboardScreen(),
          settings: settings,
        );
      case questionBank:
        return MaterialPageRoute(
          builder: (_) =>
          const QuestionBankScreen(),
        );

      case addQuestion:
        return MaterialPageRoute(
          builder: (_) =>
          const AddEditQuestionScreen(),
        );

      case editQuestion:
        final questionId =
        settings.arguments as String?;

        return MaterialPageRoute(
          builder: (_) => AddEditQuestionScreen(
            questionId: questionId,
          ),
        );

      case createQuiz:
        return MaterialPageRoute(
          builder: (_) =>
          const CreateQuizScreen(),
        );

      case myQuizzes:
        return MaterialPageRoute(
          builder: (_) =>
          const MyQuizzesScreen(),
        );

      case teacherAttempts:
        final args =
        settings.arguments
        as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) =>
              StudentAttemptsScreen(
                quizId:
                args?['quizId'] as String?,
                quizTitle:
                args?['quizTitle'] as String?,
              ),
        );

      case teacherProfile:
        return MaterialPageRoute(
          builder: (_) =>
          const TeacherProfileScreen(),
        );
      case controllerDashboard:
        return MaterialPageRoute(
          builder: (_) => const ControllerDashboardScreen(),
          settings: settings,
        );

    // =====================================================
    // UNKNOWN
    // =====================================================

      default:
        return MaterialPageRoute(
          builder: (_) => const _UnknownRouteScreen(),
          settings: settings,
        );

    }

  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 16),

              const Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.roleSelection,
                        (route) => false,
                  );
                },
                child: const Text('Go to Role Selection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}