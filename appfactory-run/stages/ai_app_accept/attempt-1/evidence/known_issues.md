# known_issues — ai_app_accept attempt-1 (non-blocking)

Controller option A (2026-10-14): soft UL-07 visual deltas → known_issues; do not block delivery; no attempt-2 / no pm_docs reopen / no blind ai_build.

| id | frame / topic | summary | severity |
|---|---|---|---|
| KI-ul07-diagram-overlay | diagram-overlay | Runtime still is Job hub (Generate / Diagram preview list) with draft toast concept; true DiagramOverlayView Use/Discard + assistive numbers not on sealed still (`runtime-diagram-overlay.r3` **fail**). Overlay concept present via Generate path; non-core visual. | soft / known_issues |
| KI-ul07-settings-units | settings-units-privacy | Settings still shows Legal (Privacy/Terms/Support/Provider policy) + permissions copy; Units control only partially visible / Revoke not co-visible (`runtime-settings-units-privacy.r3` soft/uncertain). Units + legal reachable via UL-06 UITest. | soft / known_issues |

Cleared: `home-empty` — r3 runtime vision **pass** (BendCoach AI empty home + Start a bend job / Open coach + Imperial).

Not blockers: UL-01–06 and UL-08 pass; sell-path UITests passed; four Info.plist permissions present from build.
