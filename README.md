# CareMatch

CareMatch is a Flutter app that helps patients find the right doctors for their specific health issue, book appointments, and consult by chat or video. Doctors have a separate dashboard for managing their schedule and patient appointments.

## What you can do

| Patients | Doctors |
| --- | --- |
| Describe symptoms for AI-assisted guidance and doctor suggestions | See upcoming consultations and today's schedule |
| Search doctors by name, specialty, or clinic | Review appointments and update their status |
| Book chat, video, or in-person appointments | Consult with patients through chat or video |
| View medical reports, prescriptions, and appointment history | Maintain practice and profile details |

The app supports light and dark themes and includes English and Bangla localization. Symptom guidance is intended to help patients find care.

## Run locally

Use a Flutter SDK with Dart 3.12.2 or newer in the 3.x series. The bundled Firebase configuration targets **Android and iOS**. Start an emulator or simulator, or connect a device.

```sh
flutter pub get
flutter devices
flutter run
```

If you use a different backend, update `ApiEndpoints.baseUrl` in [constants.dart](lib/core/constants/constants.dart). For a separate Firebase project, regenerate [firebase_options.dart](lib/firebase_options.dart) and configure the corresponding platform apps. The backend and client must use the same Firebase project for authentication and live chat.

## How it fits together

- **Flutter, Riverpod, and GoRouter** handle the UI, state, and navigation. Feature code lives in [`lib/features/`](lib/features), with shared services and theming in [`lib/core/`](lib/core).
- **Firebase Auth and Dio** handle sign-in and authenticated API requests. Firebase initializes during [app startup](lib/bootstrap.dart).
- **Cloud Firestore and Agora** support live chat updates and video calls. See [chat setup](docs/consultation-chat.md) for the required rules and index.
- **Hosted checkout** opens in a WebView. The app confirms bookings after the backend reports payment as paid. See [payment setup and behavior](docs/appointment-payment.md).

## Development checks

```sh
flutter analyze
flutter test
```

The [test suite](test) covers feature logic and screen interactions. Testing live chat, video calls, and hosted payments end to end requires a configured backend and compatible device.
