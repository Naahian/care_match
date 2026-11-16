# Appointment checkout

The Pay & confirm button on `AppointmentPaymentScreen` validates billing details, creates the appointment, and POSTs the required payment fields to `/payments` using the shared authenticated Dio client. The returned HTTPS `checkout_url` opens in a WebView. The JSON API itself is not loaded inside the WebView.

The appointment ID comes from the booking API, the patient ID from the signed-in session, and the amount from the displayed BDT total, including the service fee. Amounts are sent in hundredths: BDT 104 becomes `amount_cents: 10400`. Contact details are prefilled from the auth session when available; the patient supplies missing billing fields. Country is Bangladesh.

Bookings send the selected `appointment_type` as `video`, `chat`, or `in_person`.
My Appointments reads this type and `patient_name` from the backend: video cards
offer Join video consultation, chat cards open the participant conversation, and
in-person cards display the visit type. Patient cards have no cancellation action.
Doctor cards can mark active appointments of every type as completed or cancel
them. Status changes are confirmed by the server before cards move tabs. The
backend cancels unfinished appointments after their calendar date passes in its
configured timezone (default Asia/Dhaka); refresh appointments to see changes.

The same booking attempt retains its appointment ID, original payload, and random idempotency key after a payment initialization error. If appointment creation times out or returns an uncertain result, automatic rebooking is blocked; check My appointments before starting again. Checkpoints live for the lifetime of this payment screen and are not persisted across app restarts.

Checkout polls authenticated `GET /payments/{payment_id}` every five seconds and offers a manual status check. Only backend status `paid` opens the appointment confirmation screen. Browser navigation alone is not treated as proof of payment. Pending, failed, cancelled, and review results do not show success. Closing checkout triggers another status check and preserves the current session while this screen remains open.

The WebView is provided by the [Flutter WebView package](https://pub.dev/packages/webview_flutter), on Android, iOS, and macOS. Unsupported platforms show an explanation before any booking request. Firebase bearer tokens are sent to the backend only, never attached to hosted checkout requests. Checkout navigation requires HTTPS.

The deployed backend must support POST `/appointments`, POST `/payments`, GET `/payments/{payment_id}`, and SSLCommerz callbacks, with store credentials and a publicly reachable HTTPS callback origin configured. This change does not change deployment settings or process a real payment. After fetching dependencies, restart the app fully to register the WebView plugin, then verify a sandbox checkout on a supported device.

Repository, workflow, and controller tests cover the payload, auth header, malformed responses, amount conversion, retry checkpoints, and server-confirmed status. Screen tests cover validation and responsive layout. A real gateway/WebView transaction requires a device and configured sandbox backend.
