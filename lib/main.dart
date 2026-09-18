import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import ' core/ routes/app_routes.dart';
import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Helpful while testing.
  OneSignal.Debug.setLogLevel(
    OSLogLevel.verbose,
  );

  OneSignal.initialize(
    '78f04c45-263c-4e50-ab8c-1393a866465a',
  );

  // Ask Android user for notification permission.
  await OneSignal.Notifications
      .requestPermission(false);

  runApp(
    const BGQuizLabApp(),
  );
}

class BGQuizLabApp extends StatelessWidget {
  const BGQuizLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BG Quiz Lab',
      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.splash,

      onGenerateRoute:
      AppRoutes.generateRoute,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
        const Color(0xFFF7F9FC),
      ),
    );
  }
}