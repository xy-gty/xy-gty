# CellarCue — acceptance

idea_source: operator_external  
config_mode: local_only

## Runtime paths (expected)

1. **Home → Capture → OCR:** Shoot label → (consent) → large OCR hero + bin write + aging timeline; banners show 非侍酒认证 / not a sommelier certification and 非投资建议 / not investment advice; 21+ visible
2. **Import path:** Photos import label still → same Label Result
3. **Chat + speech:** Ask window/pairing via keyboard and via Speech Recognition; answers never claim certification or investment returns
4. **Rack card + TTS:** Annotate → Keep → Play brief (script includes compliance + 21+)
5. **Voice note:** Record while on cellar surfaces; attach to bottle/bin
6. **Persist:** Kill app → relaunch → Save Bottle session, chat, rack card restored
7. **Reject path:** Dismiss OCR candidates → not written; still kept as draft
8. **Unconfigured AI:** No key → honest state; local capture/notes work
9. **Revoke:** Settings revoke → outbound blocked until re-consent
10. **Legal local:** privacy / terms / support / provider policy load from bundled pages

## Eight UltraLite domains

| check_id | Mapping |
|----------|---------|
| UL-01 build_launch | com.lingguang.cellarcue; iPhone 17 Pro (B14CC0EA); Cellar Home launches |
| UL-02 core_flows | F1–F10 paths above; empty/error/cancel recoverable |
| UL-03 live_ai | Real DeepSeek when key present; else `ai_key_unavailable` gap with honest UI |
| UL-04 reviewed_persistence | Save Bottle / Keep / Use write; Reject/Dismiss do not; restart match |
| UL-05 feedback_reuse | Second Identify/chat includes confirmed notes / corrections |
| UL-06 privacy_permissions | Consent gate; Camera/Photos/Mic/Speech real; revoke stops send; local legal loads |
| UL-07 ui_interaction | Row/bin grid + OCR hero + aging timeline readable; compliance + 21+ visible; keyboard safe |
| UL-08 repo_evidence | cellarcue product_dir; branch/commit bound; no twin UI of MixCue/SporeCue/etc. |

## Compliance acceptance (hard)

- Fail if any alcohol-advice surface lacks 「非侍酒认证 / not a sommelier certification」 or 「非投资建议 / not investment advice」
- Fail if alcohol-advice surfaces lack 21+ wording
- Fail if copy claims certified tasting advice or guaranteed investment returns

## Permissions

| Permission | Proof |
|------------|-------|
| Camera | Capture label/cork/bin-tag for ID & placement |
| Photos | Import label album still |
| Microphone | Hands-free bin notes / pull brief while carrying bottles |
| Speech Recognition | Spoken coach question into window/pairing chat |

## AI consent & provider

- Provider: DeepSeek
- Disclose fields: label still, question, confirmed bottle notes, bottle/bin id, optional transcript
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
