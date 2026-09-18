import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_service.dart';
import 'onesignal_service.dart';

enum LoginResult {
  verified,
  needsVerification,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;

  // =========================================================
  // REGISTER STUDENT
  // =========================================================

  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    required String classBatch,
    required String campus,
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Unable to create student.');
    }

    await user.updateDisplayName(name.trim());

    await _firestore.saveStudent(
      uid: user.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      classBatch: classBatch.trim(),
      campus: campus.trim(),
    );

    // We want the user to login after signup.
    await _auth.signOut();
  }

  // =========================================================
  // REGISTER TEACHER
  // =========================================================

  Future<void> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String departmentCourse,
    required String campus,
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Unable to create teacher.');
    }

    await user.updateDisplayName(name.trim());

    await _firestore.saveTeacher(
      uid: user.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      departmentCourse: departmentCourse.trim(),
      campus: campus.trim(),
    );

    await _auth.signOut();
  }

  // =========================================================
  // REGISTER CONTROLLER
  // =========================================================

  Future<void> registerController({
    required String name,
    required String email,
    required String password,
    required String designation,
    required String campus,
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Unable to create controller.');
    }

    await user.updateDisplayName(name.trim());

    await _firestore.saveController(
      uid: user.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      designation: designation.trim(),
      campus: campus.trim(),
    );

    await _auth.signOut();
  }
// =========================================================
// ONESIGNAL USER SYNC
// =========================================================

  Future<void> _syncOneSignalUser({
    required User user,
    required String role,
  }) async {
    String? classBatch;

    // Students need classBatch for targeted notifications.
    if (role == 'student') {
      final studentDoc =
      await FirebaseFirestore.instance
          .collection('student')
          .doc(user.uid)
          .get();

      if (studentDoc.exists) {
        classBatch =
            studentDoc.data()?['classBatch']?.toString();
      }
    }

    await OneSignalService.loginUser(
      userId: user.uid,
      role: role,
      classBatch: classBatch,
    );
  }
  // =========================================================
  // LOGIN
  // =========================================================

  Future<LoginResult> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    final credential =
    await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Unable to login.');
    }

    // Check Firestore role.
    final actualRole =
    await _firestore.getUserRole(user.uid);

    if (actualRole == null) {
      await signOut();

      throw FirebaseAuthException(
        code: 'profile-not-found',
        message: 'User profile was not found.',
      );
    }

    // Prevent Student account from logging into Teacher portal etc.
    if (actualRole != expectedRole) {
      await signOut();

      throw FirebaseAuthException(
        code: 'wrong-role',
        message:
        'This account belongs to the $actualRole portal.',
      );
    }

    // First login -> verification email.
    if (!user.emailVerified) {
      await user.sendEmailVerification();

      return LoginResult.needsVerification;
    }

// Connect verified Firebase user to OneSignal.
    await _syncOneSignalUser(
      user: user,
      role: actualRole,
    );

    return LoginResult.verified;

  }

  // =========================================================
  // EMAIL VERIFICATION
  // =========================================================

  Future<bool> checkEmailVerification() async {
    await _auth.currentUser?.reload();

    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    if (!user.emailVerified) {
      return false;
    }

    final role =
    await _firestore.getUserRole(user.uid);

    if (role != null) {
      await _syncOneSignalUser(
        user: user,
        role: role,
      );
    }

    return true;
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // =========================================================
  // PASSWORD RESET
  // =========================================================

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  // =========================================================
  // CURRENT ROLE
  // =========================================================

  Future<String?> getCurrentRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore.getUserRole(user.uid);
  }

  // Wait for Firebase to restore existing login session.
  Future<User?> getRestoredUser() async {
    final user =
    await _auth.authStateChanges().first;

    if (user == null) {
      return null;
    }

    // Refresh Firebase user so email verification
    // status is current.
    await user.reload();

    final refreshedUser =
        _auth.currentUser;

    if (refreshedUser == null) {
      return null;
    }

    if (refreshedUser.emailVerified) {
      final role =
      await _firestore.getUserRole(
        refreshedUser.uid,
      );

      if (role != null) {
        await _syncOneSignalUser(
          user: refreshedUser,
          role: role,
        );
      }
    }

    return refreshedUser;
  }  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> signOut() async {
    await OneSignalService.logoutUser();
    await _auth.signOut();
  }
}