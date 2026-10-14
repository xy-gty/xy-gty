# ScoutCue — acceptance.md

config_mode: local_only  
privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN  

## Runtime paths（预期）

| id | path | expected |
|----|------|----------|
| P1 | Home → Import → Scene review → Keep | Scout card persists after relaunch |
| P2 | Card → select golden window on sky-arc | TimingWindow bound on plan |
| P3 | Coach ask timing → consent → reply → Keep | CoachTurn stored; Discard writes nothing |
| P4 | Overlay add marks → Save | OverlayMark list on plan |
| P5 | Next stop → Play briefing | TTS speaks BriefingClip queue |
| P6 | Dictate note → Save | ShootNote on plan |
| P7 | Settings revoke consent | Outbound blocked until re-allow |
| P8 | No AI key | Honest not-configured; local windows/cards still work |

## 八域映射

| check_id | covers |
|----------|--------|
| UL-01 | Launch ScoutCue `com.lingguang.scoutcue` on iPhone 17 Pro Simulator |
| UL-02 | P1–P6 core flows; empty/error/cancel recoverable |
| UL-03 | Live coach when key present; else honest local-only + gap `ai_key_unavailable` |
| UL-04 | Keep/Discard/Edit; restart persistence |
| UL-05 | Second coach call includes prior Keep labels/windows/notes |
| UL-06 | Consent before send; revoke; local legal pages; Camera/Photos/Mic/Speech entries |
| UL-07 | Frames vs runtime: sky-arc, soft stack, overlay pins, palette, no black/DimCue/KnotCue twins |
| UL-08 | Evidence bound to product commit / attempt |

## Permissions（必测入口）

| key | copy (product) |
|-----|----------------|
| NSCameraUsageDescription | On-site composition capture + scene recognition for scouting |
| NSPhotoLibraryUsageDescription | Import prior scouting shots; recompute best shoot windows |
| NSMicrophoneUsageDescription | Dictate shoot notes and intent into the scout plan |
| NSSpeechRecognitionUsageDescription | Turn spoken intent such as golden-hour ridge timing into a timed plan and coach chat |

Simulator：旅程与入口；设备相机/麦克风可标 真机待测。

## AI consent

- Provider：DeepSeek  
- disclosure_version：`scoutcue.consent.v1`  
- Fields：scene_labels, shot_meta, plan_windows, user_chat_text, voice_transcript, overlay_notes  
- Opt-in before first send；Settings revoke；provider policy + local privacy reachable  

## Gaps（非施工门）

- legal_url_unknown / ai_key_unavailable / cloudkit_unconfigured / feishu_row_not_yet_created  
- operator_pricing_deferred_free_app_only（goal paid packs）  
- Feishu delivery tracker skipped per operator  

## review_controls

confirm: Keep · reject: Discard · edit: Edit labels
