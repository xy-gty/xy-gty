# Controller repair brief (attempt-2 / 修复轮次 1)

Authorized by App 工厂产包主控 + packaging resume: continue product repair → ai_app_build.

## Literal gap from ai_app_accept attempt-1 MAP
- MAP: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/stages/ai_app_accept/attempt-1/MAP.md`
- map_sha256: `ccaa83545247a984fad98b49968f7610463d19307eb81529fe8b73d2fc6f103b`
- UL-02 fail / UL-04 fail / UL-05 fail / UL-07 fail (2/8)
- Active punch hub CTAs (`Add photos` / `Review snags` / `Chat fill` / `Annotate` / `Read aloud`) do not navigate to destination screens.
- Home empty + Settings/legal/local AI-unavailable messaging pass (UL-01/03/06/08).
- `suggested_node: ai_build`

## Required product fix (scope)
1. From Active punch hub, each CTA must navigate to its destination (Capture/import, Recognition review, Chat fill, Annotated report, TTS coach).
2. PunchItem save/persistence path must be reachable after navigation (UL-04).
3. Chat fill feedback/reuse reachable (UL-05).
4. Re-verify UL-07 runtime screens for the five hub destinations (+ home/settings already pass).
5. Do **not** treat known gaps as blockers: `ai_key_unavailable`, legal URL UNKNOWN, CloudKit, feishu deferred, pricing deferred, device capture pending.

## Preserve
- Prior product commit `9b7db33a…` work; only repair affected navigation/routing modules.
- Publish new `candidate_unaccepted` after compile + domain tests + smoke.
- Write MAP last; finish via official `cursor-package ultra-lite finish`.
