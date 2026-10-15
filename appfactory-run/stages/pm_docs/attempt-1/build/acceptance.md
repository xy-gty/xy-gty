# SporeCue — acceptance

idea_source: operator_external  
config_mode: local_only

## Runtime paths (expected)

1. **Home → Capture → ID:** Shoot gill/pore → (consent) → ranked stack + closeup bar + chips; banner shows 非可食认证 / not an edibility certification
2. **Import path:** Photos import hike still → same ID Result
3. **Chat + speech:** Ask lookalike question via keyboard and via Speech Recognition; answers never say safe to eat
4. **Overlay + TTS:** Annotate → Keep → Play brief (script includes disclaimer)
5. **Voice note:** Record while on field surfaces; attach to session
6. **Persist:** Kill app → relaunch → Save Find session, chat, overlay restored
7. **Reject path:** Dismiss candidates → not written; still kept as draft
8. **Unconfigured AI:** No key → honest state; local capture/notes work
9. **Revoke:** Settings revoke → outbound blocked until re-consent
10. **Legal local:** privacy / terms / support / provider policy load from bundled pages

## Eight UltraLite domains

| check_id | Mapping |
|----------|---------|
| UL-01 build_launch | com.lingguang.sporecue; iPhone 17 Pro (B14CC0EA); Field Home launches |
| UL-02 core_flows | F1–F10 paths above; empty/error/cancel recoverable |
| UL-03 live_ai | Real DeepSeek when key present; else `ai_key_unavailable` gap with honest UI |
| UL-04 reviewed_persistence | Save Find / Keep / Use write; Reject/Dismiss do not; restart match |
| UL-05 feedback_reuse | Second Identify/chat includes confirmed notes / corrections |
| UL-06 privacy_permissions | Consent gate; Camera/Photos/Mic/Speech real; revoke stops send; local legal loads |
| UL-07 ui_interaction | Stack + oversized bar + chip rail readable; disclaimer visible; keyboard safe |
| UL-08 repo_evidence | sporecue product_dir; branch/commit bound; no twin UI of MixCue/etc. |

## Compliance acceptance (hard)

- Fail if any ID/edibility/foraging surface lacks 「非可食认证 / not an edibility certification」
- Fail if copy implies safe to eat / confirmed edible / certified for consumption
- Chip rail must remain informationalOnly

## Permissions

| Permission | Proof |
|------------|-------|
| Camera | Capture still for ID |
| Photos | Import hike album still |
| Microphone | Voice note while foraging |
| Speech Recognition | Spoken coach question |

## AI consent & provider

- Provider: DeepSeek
- Disclose fields: still, question, confirmed notes, session id, optional transcript
- Refuse → local-only retained
- Settings revoke immediate
- provider-policy + local privacy/terms/support pages

## P1 config gaps (non-blocking)

```
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```

- Legal acceptance = local legal page loads
- `record_match_error=0` → feishu_row_not_yet_created gap
- Feishu CONTROLLER_DELIVERY skip
- Option A soft known_issues for non-core UL fails
- Operator pricing / one-time unlock deferred (`operator_pricing_deferred_free_app_only`)

## Simulator

iPhone 17 Pro ONLY prefer B14CC0EA — NEVER Pro Max.
