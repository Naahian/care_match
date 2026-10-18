# care_match

A new Flutter project.

## Secure storage

`StorageService` in `lib/core/services/storage_service.dart` uses
`flutter_secure_storage` for strings and JSON-compatible maps:

```dart
final storage = StorageService();
await storage.writeString(key: 'token', value: 'your-token');
final token = await storage.readString(key: 'token');
await storage.writeMap(key: 'profile', value: {'name': 'Patient', 'age': 30});
final profile = await storage.readMap(key: 'profile');
await storage.delete(key: 'token');
```

Missing keys return `null`. Invalid JSON or non-object values cause `readMap` to
throw `FormatException`. The service also supports `containsKey` and `deleteAll`,
and accepts a configured `FlutterSecureStorage` instance through its constructor.
Follow the package's [platform setup instructions](https://pub.dev/packages/flutter_secure_storage)
for Android backups, Apple Keychain capabilities, Linux dependencies, and web
HTTPS requirements before testing on those platforms.

## Firebase authentication

`lib/core/services/firebase_auth_service.dart` provides email/password sign-up
and sign-in, password reset, email verification, auth/token streams, ID tokens,
native phone OTP (including resend callbacks), web phone verification, credential
sign-in, and sign-out. It accepts a `FirebaseAuth` instance for dependency
injection and preserves `FirebaseAuthException` codes for UI error handling.

Firebase is configured through `lib/firebase_options.dart` for Android and iOS.
`main()` awaits `bootstrap`, which initializes Firebase and injects the app's
`FirebaseAuthService` into `ProviderScope` before mounting the UI. Enable the
Email/Password and Phone sign-in providers in the Firebase console. Re-run
`flutterfire configure` when adding supported platforms.

Phone verification requires platform setup (Android SHA fingerprints, iOS APNs
configuration, and web authorized domains if web support is added).
See the [Firebase setup guide](https://firebase.google.com/docs/flutter/setup)
and [phone authentication guide](https://firebase.google.com/docs/auth/flutter/phone-auth).

The auth feature's data layer composes both services:

```dart
final AuthRepository authRepository = AuthRepositoryImpl(
  remoteDataSource: AuthRemoteDataSource(authService: FirebaseAuthService()),
  localDataSource: AuthLocalDataSource(storage: StorageService()),
);
final user = await authRepository.signInWithEmailAndPassword(
  email: 'patient@example.com',
  password: password,
);
```

`AuthUserModel` maps Firebase profiles to the domain `AuthUser` entity and JSON.
Successful sign-up, sign-in, OTP confirmation, and `reloadUser` cache the profile
under `auth.user.v1`. `getCachedUser` discards corrupt snapshots and snapshots
that do not match the current Firebase user. Auth/token streams and `currentUser`
always come from Firebase; cached data never establishes a session. Passwords
and tokens are not cached by the repository. Firebase manages session persistence
and token refresh as described in the [Firebase Auth guide](https://firebase.google.com/docs/auth/flutter/start).
Use repository `confirmPhoneNumber` for web OTP so the confirmed profile is cached.
Sign-out removes only the auth cache after Firebase succeeds. Storage errors
propagate; if caching fails after sign-in, Firebase may already be signed in.

## Auth controller

`AuthController` uses an explicit immutable `AuthState` and a
`NotifierProvider`. The app entry point installs `ProviderScope`. Import
`lib/features/auth/providers.dart` in a Riverpod consumer to watch state and
invoke actions:

```dart
final auth = ref.watch(authControllerProvider);
final succeeded = await ref.read(authControllerProvider.notifier).signIn(
  email: email,
  password: password,
);
```

State exposes the current domain user, `isAuthenticated`, `isLoading`,
`pendingAction`, `errorMessage`, and phone verification details. Actions include
email sign-in/sign-up, credential sign-in, password reset, email verification,
user refresh, sign-out, requesting/resending OTP, and verifying SMS codes.
For native OTP, wait for `codeSent` or `isAuthenticated`; requesting verification
can finish before its callbacks. Call `clearPhoneVerification` when changing
the number or abandoning the OTP flow to ignore old callbacks.

`authRepositoryProvider` and `snackbarProvider` are overridable for tests. The
controller shows success/info/error snackbars and leaves navigation to the UI.
It calls the repository directly; no additional domain orchestration requires
a use case. No UI model is needed for the existing domain user and OTP fields.
Login, create-account, and phone-verification screens now consume the controller.
Login validates email/password and enters home only after success. Registration
uses the public backend POST endpoints in `ApiEndpoints`: `/createPaitent`
(spelling matches the backend) and `/createDoctor`. The backend creates the auth
account. Patient requests contain `email`, `password`, and `display_name`;
doctor requests also include phone, clinics, specialties, degrees, available
time ranges, and weekdays. The account-type selector reveals the doctor fields.
Any 2xx status succeeds without requiring a response body, then returns to login.
Registration does not create a local Firebase session, cache a user, or send a
verification email from the client. Login still uses Firebase, so backend-created
accounts must be available there. HTTP 422 field messages are shown without
echoing `input`, `ctx`, or password values. Other failures use safe messages.
The separate phone-verification screen supports resend and automatic completion.
See [Firebase account linking](https://firebase.google.com/docs/auth/flutter/account-linking).
Widget tests override repository and snackbar providers and do not send SMS.

## Temporary appointment confirmation

The appointment payment step currently sends “Pay & confirm” directly to the
appointment confirmation screen with the selected booking draft. No payment
is collected or verified in this temporary flow.

## Feature API requests

Configure the backend URL when running or building the app:

```sh
flutter run --dart-define=API_BASE_URL=https://your-api.example.com/api
```

Restart the app after changing a Dart define. Firebase login and auth screens
can load without this setting; submitting registration requires a valid backend
URL and shows a configuration message if the setting is missing or invalid.

Feature data sources should receive `Dio` through constructor injection. Their
providers can pass `ref.watch(dioProvider)` from `lib/core/providers.dart`.
The shared client supports Dio's typed CRUD methods:

```dart
final response = await dio.get<Map<String, dynamic>>('/patients/123');
await dio.post<Map<String, dynamic>>('/patients', data: {'name': 'Patient'});
await dio.put<Map<String, dynamic>>('/patients/123', data: {'name': 'Updated'});
await dio.patch<Map<String, dynamic>>('/patients/123', data: {'name': 'Updated'});
await dio.delete<void>('/patients/123');
```

`AuthInterceptor` fetches the current Firebase ID token for each authenticated
request and sets `Authorization: Bearer <token>`. Firebase manages token renewal.
Signed-out requests fail before network access. For public endpoints, import
`core/network/interceptors/auth_interceptor.dart` and use
`Options(extra: {AuthInterceptor.requiresAuth: false})`; no authorization header
is sent. The client restricts requests to the configured API origin and does not
automatically follow authenticated redirects or retry failed CRUD requests.
Handle `DioException` in feature data sources/repositories, including HTTP 401s.

`apiBaseUrlProvider`, `accessTokenReaderProvider`, and `dioProvider` can be
overridden in tests or when a backend uses a different bearer-token source.
The backend must accept Firebase ID tokens when using the default token reader.
See the [Dio documentation](https://pub.dev/packages/dio) for cancellation,
multipart uploads, and response options.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
