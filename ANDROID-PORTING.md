# NOX STUDY — Android port requirements

This repository currently contains a web app (`index.html`), not a native Android project. Packaging the page in a WebView does **not** grant it permission to block other apps or provide cross-device accounts.

## Before calling the Android build complete

### Focus mode / social app blocking
- Implement a native Android `AccessibilityService` only after a clear, user-initiated explanation and consent. Use it to detect selected app switches and show a blocking screen for apps the user selected.
- Let the user choose which apps to block. Keep YouTube excluded by default as requested, but do not promise to block apps while the accessibility service is disabled or restricted by the OS.
- Explain Android settings, battery/background limits, and provide an obvious pause/disable control. Do not collect screen content or transmit it.
- Test on a real Android device, including app restart, screen lock, battery saver, service revocation, and attempts to open selected social apps.

### Accounts, friend codes, requests, shared tasks
- Use a real authenticated backend; localStorage is only for data on one device and cannot deliver requests between friends.
- Generate non-secret, unique public friend IDs on the server. Validate incoming requests, allow accept/decline/block, rate-limit lookups, and never expose email/password in friend codes.
- Store shared tasks with owner/member permissions, server timestamps, and authorization checks. Sync updates to both users. Add report/block controls and do not reveal private study notes by default.
- Until the backend exists, label friend features as a preview and never claim requests or shared tasks are synced.

### YouTube lesson cards
- Embedded playback can fail if a video disables embedding.
- For an accurate summary, obtain captions/transcript with permission or let the learner paste a transcript. Generate a summary and review questions from that text, show the source, and allow edits before saving.
- Do not claim a summary was extracted from the video when only the URL was supplied.

### Verification checklist
- Test the daily goal across date rollover and timezone changes.
- Test focus timer pause/resume, reset, rest transitions, and app background/foreground.
- Test cards, PDF import/annotations, task persistence, and existing navigation.
- Verify all permissions and data flows on-device. Do not merge this branch into `main` until the user approves.
