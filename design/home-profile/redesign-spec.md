# Home and doctor profile concept

Requested 2026-11-02 by continuation of onboarding image redesign. Use built-in imagegen, source `current-home-profile.png`, style reference `../onboarding/onboarding-calm-teal-v1.png` (unapproved draft, consistency reference for this iteration only), and direction `../ui-design-brief.md`.

Prompt specification: two full front-facing mobile screens side by side, no device hardware; Calm Teal palette #F5F9F9/#FFFFFF/#163238/#087F8C, soft flat, subtle aurora on AI panel, Manrope-like headings and Inter-like body, 20px cards, consistent outline icons, comfortable spacing. Preserve home symptom prompt/input, four quick actions, featured doctor cards, four-tab navigation. Preserve doctor profile, specialty, tags, bio, rating, chat/video consultation prices, and booking action. Translate blue/purple source styling into teal. Portraits are illustrative. Doctor names, credentials, ratings, reviews, availability and consultation fees are supplied source mockup content, not verified real-world facts. No additional claims or treatment recommendations.

Source labels and numbers: Dr. Emily Carter, Internal Medicine, 4.9 (1.2k reviews); Dr. James Patel, Family Medicine, 4.8 (842 reviews); Available today; Chat consult $49, Video consult $79. Bio describes source's 10+ years and board-certified internist. Output is a raster concept, not editable Figma or an implemented application.

Output: `home-profile-calm-teal-v1.png`. Built-in imagegen; draft/unapproved. Inspected generated board: both complete frames and primary actions visible, labels legible, source features preserved, teal controls and consistent surfaces. Typography and color reproduction remain approximate. The final home card sits close to bottom navigation; implementation should ensure scroll clearance. No accessibility or functionality validation claimed.

## Revision 2: structural redesign requested

User rejected v1's composition similarity. Content remains source-driven, layout is redesigned: home uses open heading and compact AI input, teal consultation banner with chat/video actions, two broad doctor/care utility tiles, side-by-side vertical featured doctor cards, floating navigation dock. Profile uses split text/portrait hero, editorial About section, two side-by-side selectable consultation price tiles and sticky booking summary/action. Calm Teal palette and Manrope/Inter direction retained. Built-in imagegen using the original screenshot as content inventory only, explicitly prohibiting layout reuse. Draft pending inspection.

Revision 2 output: `home-profile-calm-teal-v2.png`, draft/unapproved. Inspected: new consultation banner, compact AI input, wide utility tiles, side-by-side doctor cards and floating dock; split profile header, side-by-side consultation selectors, booking summary footer. All core source content and actions visible. Sample source doctor details preserved. Font and color reproduction approximate. No implementation/accessibility certification claimed.

## Revision 3: restrained professional direction

User requested a professional design after v2. Rebuilt from content rather than using rejected layouts as visual references. Reduced typography scale, radius and ornamentation; removed saturated promotional banner, decorative imagery, floating navigation and large price tiles. Home now uses a compact symptom input, portrait/list doctor entries with fine separators, and a flat two-column service menu. Profile uses a compact editorial identity block, plain-text expertise, About, a single grouped selectable consultation control, and a quiet booking footer. White and charcoal dominate; teal defines interactions. Reduced radius around 10–12px is an intentional refinement of the earlier 20px direction in response to latest feedback. Portraits are generated sample people. All doctors' claims/prices/ratings remain source mockup content, unverified.

Full generation prompt: `professional-v3-prompt.txt`. Built-in imagegen used. Targeted correction: My care helper becomes 'Reports and prescriptions'; footer becomes 'Chat consultation selected' to match selected control. Raster only, draft/unapproved. No application code or Figma frames created.

Final v3 output: `home-profile-professional-v3.png`. Inspected final board: both frames and bottom actions visible; My care correctly references reports/prescriptions; chat selected state matches footer; no obvious overlapping or clipped text. The visual is a raster concept, not tested implementation or guaranteed font fidelity. No approval inferred.
