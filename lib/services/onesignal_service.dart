import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  OneSignalService._();

  static Future<void> loginUser({
    required String userId,
    required String role,
    String? classBatch,
  }) async {
    // Firebase UID becomes OneSignal External ID
    await OneSignal.login(userId);

    final Map<String, dynamic> tags = {
      'role': role,
    };

    // Student also gets classBatch tag
    if (role == 'student' &&
        classBatch != null &&
        classBatch.trim().isNotEmpty) {
      tags['classBatch'] = classBatch.trim();

      await OneSignal.User.addTags(tags);
    } else {
      // Teacher / Controller
      await OneSignal.User.addTags(tags);

      // Remove old student batch if the same phone
      // was previously used by a student account.
      await OneSignal.User.removeTag(
        'classBatch',
      );
    }
  }

  static Future<void> logoutUser() async {
    await OneSignal.logout();
  }
}