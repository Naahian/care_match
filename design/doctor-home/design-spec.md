# Doctor home dashboard

Requested 2026-11-02. Raster image concept requested by continuation of image design workflow; no application implementation or Figma output requested.

## Confirmed requirements

Use the newly supplied patient-home screenshot as the visual reference. Its navy/blue/mint palette and existing UI patterns take precedence over previous exploratory home/profile draft styling for this deliverable.

- Four summary metrics: upcoming consultations, appointments today, in-person appointments, total earnings.
- Exactly three shortcut buttons: Chats, Video, Prescriptions.
- Exactly three bottom navigation destinations: Home, Notifications, Profile. Remove Doctors/search navigation.
- No AI/symptom card.
- Consistency additions permitted by user.

## Proposed composition

Preserve CareMatch wordmark and settings gear, source font character, pale cool-white background, navy headings, medium-blue supporting text, mint selected navigation, simple outlined icons, and subtle white bordered cards. Compact greeting and equal two-by-two metric cards replace the patient AI area. Three source-style circular shortcut actions follow. Add two compact patient appointment entries with time, modality, and an action to show the next work in the doctor's day. Fixed three-item bottom navigation. Tall Android screen; no device hardware or perspective.

## Illustrative data and assumptions

08 upcoming consultations, 05 appointments today, 02 in-person today, total earnings ৳24,500 all time. Currency BDT is a design assumption, not a user-specified currency. Sample patients Nadia Rahman (10:30–11:00 AM, video) and Arif Hasan (11:15–11:45 AM, in person). Date Mon, 2 Nov. Sample counts and earnings are not factual practice data. Patient names are fictional and no medical details included. The two rows illustrate two of five appointments; View all leads to the full schedule conceptually, with no functionality claim.

Output status: draft/unapproved. Image-generation only, no code changes. Check output against exactly four metrics, three shortcuts, three navigation destinations and no AI card.

Generated: `doctor-dashboard-v1.png` using built-in imagegen. Full prompt in `generation-prompt.txt`. Final visual inspection: all four requested metric cards visible with intended values; exactly three shortcuts and three navigation destinations; no patient AI/search card or Doctors navigation; both appointment rows and bottom navigation fully visible. Palette and layout match latest supplied patient screenshot. Image remains draft/unapproved; font/color fidelity approximate. No interactive or accessibility verification claimed.

## Revision 2 requested

Metrics become near-square in a two-by-two grid. Internal card structure: column with top row of small icon and a title/subtitle text column, followed by a large number below. Replace the original three circle shortcuts with exactly two decorated destination cards: Prescription (Write and manage) and All appointments (View your schedule). This supersedes the earlier three-shortcut requirement for this doctor dashboard. Retain three-item bottom navigation and no AI card. Strengthen secondary text and borders for better visual contrast; no computed accessibility claim from raster inspection. Header whitespace and appointment rows may be compacted to fit square cards. Existing sample data preserved.

Revision 2 output: `doctor-dashboard-v2.png`, built-in imagegen, draft/unapproved. Full prompt: `revision-2-prompt.txt`. Visually inspected: four taller metric cards with icon/title/subtitle row and value below; two decorated action cards replacing circle shortcuts; three navigation items retained; stronger navy/blue-grey text; all appointment rows visible. Cards are taller rectangles approaching square, not exact geometric squares. No quantitative contrast or implementation validation claimed.
