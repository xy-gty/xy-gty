# MixCue — acceptance

config_mode: local_only

privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN  

Legal acceptance = local in-app Privacy / Terms / Support pages load. External URLs are delivery gaps (`legal_url_unknown`), not UL-06 hard fail. Provider policy must be reachable in-app.

## Runtime paths

| ID | Path | Expected |
|----|------|----------|
| P-HOME | Launch → Bar Home | Empty bottle-rail + large next-pour card + garnish chip row + Shoot/Import + coach bar |
| P-CAM | Shoot → allow Camera → capture | Draft MixSession with photo |
| P-PHO | Import → allow Photos → pick | Draft MixSession |
| P-ID | Identify with key+consent | Spirit candidates on bottle-rail + label cues |
| P-ID-NOKEY | Identify without key | Honest unconfigured; no fake spirits |
| P-CONSENT | First outbound | DeepSeek + fields disclosed; deny keeps local |
| P-CHAT | Ask coach → text/speech question | Coach turns persist; speech needs Speech Recognition |
| P-POUR | Open pour board → advance steps | Large next-pour card + garnish chips; Save Mix persists |
| P-TTS | Speak step | AVSpeech plays current pour/shake/stir instruction offline |
| P-MIC | Voice note | Mic record saves VoiceNote |
| P-SAVE | Save Mix → kill → relaunch | Confirmed spirit + pour board + chat restored |
| P-REUSE | Second Identify after Save | Request includes prior confirmed spirits |
| P-REVOKE | Settings revoke AI | Outbound blocked until re-consent |
| P-LEGAL | Settings → Privacy/Terms/Support/Provider | Local pages load |

## Eight-domain mapping

| Domain | Covered by |
|--------|------------|
| UL-01 build_launch | MixCue bundle `com.lingguang.mixcue`, iPhone 17 Pro (B14CC0EA) |
| UL-02 core_flows | P-HOME…P-POUR, P-MIC, empty/error/cancel |
| UL-03 live_ai | P-ID when key present; else P-ID-NOKEY + local smoke |
| UL-04 reviewed_persistence | Save Mix / Dismiss / Edit pour steps; P-SAVE |
| UL-05 feedback_reuse | P-REUSE |
| UL-06 privacy_permissions | Camera/Photos/Mic/Speech + P-CONSENT + P-REVOKE + local legal |
| UL-07 ui_interaction | Frames vs runtime for all frame_ids; bottle-rail / next-pour card / garnish chips species |
| UL-08 repo_evidence | mixcue/ product dir, commit-bound MAP |

## Permissions checklist

1. Camera — bottle face / label / garnish capture  
2. Photos — bar-shelf album import  
3. Microphone — hands-free voice notes while shaking/stirring  
4. Speech Recognition — spoken coach questions  

## Soft known_issues (Option A)

Non-core UL soft fails may land as `known_issues` without blocking delivery per operator Option A. P1 gaps (UNKNOWN URLs, ai_key, cloudkit, feishu_row_not_yet_created) must not block delivery.

## Feishu / delivery

CONTROLLER_DELIVERY skip per operator. identity-skeleton optional fail-soft after MAP. Deliver to `git@github.com:xy-gty/xy-gty.git` on an independent branch.
