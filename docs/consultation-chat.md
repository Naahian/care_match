# Consultation chat

The Flutter client uses authenticated REST endpoints to create/reopen chats,
load chat details, page through the inbox and message history, and send messages.
The backend stores messages in `chats/{chat_id}/messages/{message_id}` in Cloud
Firestore and updates the conversation preview transactionally. The client listens
to Firestore for live inbox/message changes; it never writes duplicate copies.

The API client and Firestore SDK must use the same Firebase project and signed-in
Firebase user. Existing application bootstrap initializes Firebase; the
`cloud_firestore` package supplies the listeners. Firestore and repository providers
are overridable in tests. No extra orchestration use case is needed: REST/Firestore
mapping and synchronization remain within the data layer and presentation controller.

## Deploy setup

`firebase.json` references `firestore.rules` and `firestore.indexes.json`. These
match the backend's chat storage. Rules allow authenticated participants to read
only their conversations/messages, deny client writes, and deny access to other
collections. Merge any existing project rules before deploying: a rules deployment
replaces the active ruleset. The inbox needs the composite index on
`participant_uids` (array contains) and `updated_at` (descending).

Deploy the rules and index to the existing Firebase project, then wait for the index
to finish building. No rules or indexes were deployed by this implementation.

```sh
firebase deploy --only firestore:rules,firestore:indexes --project care-match-backend
```

Use two signed-in accounts to verify sending through the backend updates both
clients, and verify a third account cannot read either the chat or messages.
Firebase's listener integration is documented at
https://firebase.google.com/docs/firestore/query-data/listen.

## Behavior

- Doctor profile chat/video consultation tiles open appointment booking with the
  matching consultation type. A chat URL with a `recipient` Firebase UID can still
  create/reopen a conversation through POST `/chats`. The backend reuses the
  existing conversation for that pair.
- The inbox shows shimmer cards while loading; older-page requests keep the
  current conversations visible and show an additional loading card.

- Conversation links contain `chatId`; GET `/chats/{id}` verifies membership before
  history is loaded. Participant names are shown when doctor directory data exists;
  otherwise the UI uses a neutral label, without fabricated presence or names.
- Inbox/history pagination uses `next_cursor`. Messages merge by message ID with
  server timestamps and ID tie-breakers, retaining older pages outside the live window.
- Unconfirmed sends retain their text and UUID. Definite rejections unlock editing. Retry sends the same ID and text, so an
  ambiguous timeout cannot create another copy. The composer is locked while a
  message awaits confirmation. Text is cleared only on API success.
- Resume and live windows that jump beyond loaded history fetch missing pages until
  a previously loaded message is reached. API history stays visible on transient
  live-listener failures and the UI offers reconnect. Permission failures clear it.
- App resume reopens the live listener and reconciles history. Reconnecting ignores
  obsolete catch-up results; another live-window gap during catch-up queues a fresh
  pass using the original history anchor so intervening messages are retained.
- Live or history failures do not unlock an in-flight send or chat creation.
  Each operation owns its progress state, preventing concurrent duplicate actions.
- Account changes/disposal cancel subscriptions and invalidate in-flight results.
- Background push, presence, read receipts, attachments, and video calls are outside
  this chat implementation. Video consultations are launched from an appointment
  card; see the setup below.

Tests use fake repositories/live data sources and an HTTP adapter, without a live
Firestore database or credentials. Live rules/index readiness and a two-account
smoke test remain deployment checks.

## Paid chat bookings

Checkout creates or reopens the patient/doctor chat after the backend reports the
payment as `paid` for a chat booking. This is the existing app's confirmation-screen
trigger; it does not wait for a later doctor status transition. Pending, failed,
cancelled, review, video, and in-person checkouts do not create chats.

`CreatePaidBookingChat` owns the paid/chat eligibility rule and verifies both
participants. Checkout keeps the created chat ID across payment refreshes and
prevents concurrent setup. The backend's participant-pair chat identity makes
retries safe. If chat setup fails, the successful payment remains intact; the
confirmation screen offers Retry chat setup and then Open chat. A chat-only retry
never creates another appointment or payment.

The backend appointment schema currently has no consultation-type field. If chat
creation must also occur for appointments confirmed later by a doctor, independently
of this client checkout, the backend must persist that type and perform creation
when handling its confirmation transition.

## Video consultations

The appointment card opens the video onboarding screen, then the call room requests
an authenticated POST to `/video/token` with `{"appointment_id":"<appointmentId>"}`.
The response must include `data.token` and `data.channelName`; the channel name must
match the appointment ID. Both participants join the Agora live-broadcast channel
as broadcasters, publish camera and microphone tracks, and subscribe to the other
participant. The room waits for Agora's remote-user event and leaves/releases the
engine when End call is selected or the room closes.

Set `AppConstants.agoraAppId` in `lib/core/constants/constants.dart` before testing.
Camera and microphone usage descriptions/permissions are configured for Android,
iOS, and macOS. A device or desktop with the Agora plugin and a backend that issues
valid Agora RTC tokens is required for an end-to-end call.
