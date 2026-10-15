# WingCue — acceptance

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
| P-HOME | Launch → Field Home | Empty mint field-card stack + Shoot/Import + coach bar |
| P-CAM | Shoot → allow Camera → capture | Draft IDSession with photo |
| P-PHO | Import → allow Photos → pick | Draft IDSession |
| P-ID | Identify with key+consent | Candidates + oversized chips + silhouette bar |
| P-ID-NOKEY | Identify without key | Honest unconfigured; no fake species |
| P-CONSENT | First outbound | DeepSeek + fields disclosed; deny keeps local |
| P-CHAT | Clarify → text/speech question | Coach turns persist; speech needs Speech Recognition |
| P-OVL | Annotate → Save | Overlay persisted on same photo |
| P-TTS | Speak tip | AVSpeech plays name/tip offline |
| P-MIC | Voice note | Mic record saves VoiceNote |
| P-SAVE | Save ID → kill → relaunch | Confirmed species + overlay + chat restored |
| P-REUSE | Second Identify after Save | Request includes prior confirmed marks |
| P-REVOKE | Settings revoke AI | Outbound blocked until re-consent |
| P-LEGAL | Settings → Privacy/Terms/Support/Provider | Local pages load |

## Eight-domain mapping

| Domain | Covered by |
|--------|------------|
| UL-01 build_launch | WingCue bundle `com.lingguang.wingcue`, iPhone 17 Pro (B14CC0EA) |
| UL-02 core_flows | P-HOME…P-OVL, P-MIC, empty/error/cancel |
| UL-03 live_ai | P-ID when key present; else P-ID-NOKEY + local smoke |
| UL-04 reviewed_persistence | Save ID / Dismiss / Edit marks; P-SAVE |
| UL-05 feedback_reuse | P-REUSE |
| UL-06 privacy_permissions | Camera/Photos/Mic/Speech + P-CONSENT + P-REVOKE + local legal |
| UL-07 ui_interaction | Frames vs runtime for all frame_ids; field-card/chips/silhouette species |
| UL-08 repo_evidence | wingcue/ product dir, commit-bound MAP |

## Permissions checklist

1. Camera — field plumage capture  
2. Photos — trip album import  
3. Microphone — hands-free voice notes  
4. Speech Recognition — spoken coach questions  

## Soft known_issues (Option A)

Non-core UL soft fails may land as `known_issues` without blocking delivery per operator Option A. P1 gaps (UNKNOWN URLs, ai_key, cloudkit, feishu_row_not_yet_created) must not block delivery.

## Feishu / delivery

CONTROLLER_DELIVERY skip per operator. identity-skeleton optional fail-soft after MAP.
