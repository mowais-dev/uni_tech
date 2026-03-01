// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/firebase_options.dart';

import 'providers/navigation_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously();

  // Remove # from Flutter Web URLs
  setUrlStrategy(PathUrlStrategy());

  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // SPA: no routes, no initialRoute
        home: const UniTechAdminPanel(),
        onGenerateRoute: (settings) {
          // Catch-all route: always return SPA widget
          return MaterialPageRoute(builder: (_) => const UniTechAdminPanel());
        },
      ),
    ),
  );
}

/// SPA Bootstrap Widget
class UniTechAdminPanel extends ConsumerStatefulWidget {
  const UniTechAdminPanel({super.key});

  @override
  ConsumerState<UniTechAdminPanel> createState() => _UniTechAdminPanelState();
}

class _UniTechAdminPanelState extends ConsumerState<UniTechAdminPanel> {
  @override
  void initState() {
    super.initState();

    // Set initial screen based on URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setScreenAsUrl(ref);
    });

    // Handle back/forward buttons
    web.window.onPopState.listen((event) {
      setScreenAsUrl(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    if (navState.loading) return const SplashScreen();
    return navState.widget;
  }
}
