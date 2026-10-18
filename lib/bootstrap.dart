import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/storage_service.dart';
import 'firebase_options.dart';

/// Initializes startup dependencies before mounting the application.
Future<void> bootstrap(Widget app, {StorageService? storage}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authService = FirebaseAuthService(
    auth: FirebaseAuth.instanceFor(app: firebaseApp),
  );

  runApp(
    ProviderScope(
      overrides: [
        firebaseAuthServiceProvider.overrideWithValue(authService),
        if (storage != null) storageServiceProvider.overrideWithValue(storage),
      ],
      child: app,
    ),
  );
}
