# Care Match UI design brief

Updated: 2026-11-02

## Confirmed product and direction

Care Match is an AI-powered medical app for patients to describe symptoms and find a suitable nearby specialist. Patients can consult via chat or video, book in-person visits, and access reports and prescriptions.

User-selected aesthetic: soft flat with subtle aurora accents; calm, clear controls and a distinctive AI area.

User-selected preset: Calm Teal, light appearance.

- Background: #F5F9F9
- Surface: #FFFFFF
- Primary text: #163238
- Accent: #087F8C
- Success: #237A49
- Warning: #946200
- Error: #C03636
- Headings: Manrope, weights 600–700
- Body: Inter, weights 400–500
- Cards: 20px corners; comfortable spacing; simple outline icons
- Aurora: restrained teal–blue accents around AI features; keep text and task controls clear

The user will supply existing screens later on demand. Redesign those screens using this direction; setup does not request screen generation. Create editable UI in Figma, not imagegen. Preserve product functionality while upgrading visuals; source screen details remain pending.

## Supplied visual references

Inspected attachments on 2026-11-02. Copies are relative to this brief. These are visual guides only; their copy, people, metrics, claims, and feature sets are not Care Match requirements.

1. [Medical booking](references/medical-booking.png): rounded doctor cards, appointment hierarchy, date/time selection, compact floating navigation, soft surfaces. Purple/lime palette is not selected.
2. [Editorial cards](references/editorial-cards.png): strong typography, whitespace, modular card composition, hierarchy. Marketing layout and statistics are not app requirements.
3. [Soft health assistant](references/soft-health-assistant.png): mint atmosphere, gentle tonal depth, health task tiles, distinctive AI area. Illustrative health features and decorative device presentation are not requirements.

User-confirmed blend: reference 1 for task structure, reference 3 for atmosphere, reference 2 for typography/spacing, all translated into the selected palette and fonts.

## Assumptions and defaults

Patient-facing mobile app, inferred from supplied references; final viewport/platform to follow supplied current screens. Clean screen frames without device mockups by default. No exact typography sizes, navigation model, secondary text token, aurora stops, or shared components finalized yet; derive from actual screens and record decisions as established.

## Open choices

- Onboarding source supplied: [current screens](onboarding/current-onboarding.png). Four-screen redesign requested.
- Figma connection/destination pending; assumed working frame 390 × 844.
- Source privacy/security claims need product verification; see onboarding specification.

## Screens and Figma

No screens created or approved. No Figma destination recorded. Verify connection and write capability at creation time; follow applicable Figma skills. Approved frame links and component/library references will be recorded here.

## Pending onboarding redesign

[Draft specification](onboarding/redesign-spec.md) prepared from supplied four-screen onboarding. No Figma frames generated: plugin discovery on 2026-11-02 reports Figma uninstalled. Creation awaits connection.

## Generated raster onboarding draft

User requested image generation instead of Figma for this deliverable. [Four-screen concept](onboarding/onboarding-calm-teal-v1.png) generated with built-in imagegen; draft/unapproved. Specification and correction notes: [onboarding spec](onboarding/redesign-spec.md). Figma creation remains pending; this raster does not establish approval or editable frames.

## Generated home/profile raster draft

[Home and doctor profile concept](home-profile/home-profile-calm-teal-v1.png), built-in imagegen, 2026-11-02, draft/unapproved. User supplied existing screens as continuation of image redesign. Source content retained as illustrative mockup data. [Specification](home-profile/redesign-spec.md). No Figma frames or application code created.

## User refinement: structural redesign

User rejected home/profile v1 as too close to the source: recoloring and avatar substitution are insufficient. For future redesigns, retain content/actions while actively reconsidering composition, section order, tile placement, card geometry, banner treatments, and navigation presentation. Keep an existing pattern only when it is the best fit. Do not interpret the source screenshot as a required layout. This preference supersedes v1's source-layout preservation; neither raster draft is approved.

[Structurally redesigned home/profile v2](home-profile/home-profile-calm-teal-v2.png) generated after user rejected v1 layout similarity. Draft awaiting feedback, not an approved anchor. Includes banner, doctor carousel cards, split profile header and selectable consultation tiles.

## Latest refinement: professional restraint

User requested a professional design after v2. For this iteration, prioritize measured typography, compact functional controls, clear grouping, quiet borders, natural small portraits, and restrained use of teal. Reduce decorative aurora, oversized banners, rounded cards on every section, cartoon avatars and floating navigation. Use moderate 10–12px corners where suitable. Content and actions remain; latest direction supersedes decorative treatment in earlier drafts. No new image is an approved anchor until the user approves it.

[Professional home/profile v3](home-profile/home-profile-professional-v3.png), built-in imagegen, draft awaiting review. Quiet list-based home, flat service grid and grouped consultation selector. Full generation prompt saved as [v3 prompt](home-profile/professional-v3-prompt.txt). Final image visually inspected after targeted copy correction.

## Doctor dashboard from latest patient-home reference

User supplied a new patient-home screenshot as the styling baseline and requested a doctor home. For this deliverable, match that screenshot's navy/blue/mint system rather than the earlier exploratory professional v3. [Doctor home draft](doctor-home/doctor-dashboard-v1.png), built-in imagegen, 2026-11-02. Four metrics; Chats, Video, Prescriptions shortcuts; Home, Notifications, Profile navigation; no AI card. Added compact appointment list. [Specification and sample data assumptions](doctor-home/design-spec.md). Counts, earnings, currency and names illustrative. No approval inferred.

Doctor dashboard revision: [v2 image](doctor-home/doctor-dashboard-v2.png) uses taller near-square metric cards structured as icon plus title/subtitle, then number. Exactly two decorated actions, Prescription and All appointments, replace the prior three shortcuts per user request. Stronger contrast, same three-item bottom navigation. Built-in imagegen, draft/unapproved. See [revision prompt](doctor-home/revision-2-prompt.txt).
