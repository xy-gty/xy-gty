# RuleCue — 验收合同

idea_source: operator_external  
config_mode: local_only

## Runtime paths（核心）

| ID | Path | Expected |
|----|------|----------|
| ACC-01 | New session → CaptureImport Camera | TablePhoto gains pages/layout; cancel leaves prior intact |
| ACC-02 | CaptureImport Photos import | Rulebook/table photos imported; Photos deny → honest banner + manual empty |
| ACC-03 | ComponentReview Keep/Discard/Edit | Keep writes ComponentMap + PhaseStep; Discard no write; Edit revises draft |
| ACC-04 | TableCoach zone cards + turn step bar | Zone select works; step advances; restart restores route |
| ACC-05 | CoachChat + consent + TurnReview | No send before consent; Keep persists CoachMessage; Discard no write |
| ACC-06 | SetupOverlay Keep | SetupOverlay persisted and shown on next zone |
| ACC-07 | HostTTS Play | AVSpeech plays host cue; Pause/Next work; failure text shown |
| ACC-08 | DictateRules speech | SpokenQuestion written into coach chat; mic/speech deny → manual fields remain |
| ACC-09 | Settings revoke consent | Outbound stops immediately; local capture still works |
| ACC-AI-01 | Live DeepSeek with key | Real request/response bound to GameSession context |
| ACC-AI-02 | No key / local_only | Honest not-configured; consent still blocks send |

## Eight domains mapping

| Domain | Coverage |
|--------|----------|
| UL-01 build_launch | com.lingguang.rulecue on iPhone 17 Pro (B14CC0EA); launch SessionsHome |
| UL-02 core_flows | ACC-01..09 |
| UL-03 live_ai | ACC-AI-01 or ACC-AI-02 + gap `ai_key_unavailable` |
| UL-04 reviewed_persistence | Keep writes; Discard no write; restart consistent |
| UL-05 feedback_reuse | Second coach call includes confirmed ComponentMap/PhaseStep/SetupOverlay/CoachMessage |
| UL-06 privacy_permissions | Camera/Photos/Mic/Speech real prompts; consent gate; local legal pages load; revoke stops send |
| UL-07 ui_interaction | Frames vs runtime screenshots for table zone cards + turn step bar; no twin chrome |
| UL-08 repo_evidence | product commit + MAP refs; rulecue/ dir symlink rule |

## Permissions（必测）

| Permission | Flow |
|------------|------|
| Camera | Capture rulebook pages, component close-ups, current table layout |
| Photos | Import rulebook page images / past table photos for compare |
| Microphone | Hands-free ask while setting up |
| Speech Recognition | Spoken rules questions written into coach chat and trigger next tip |

Device camera/mic/speech may mark 真机待测; Simulator still exercises journey entry points on iPhone 17 Pro ONLY (prefer B14CC0EA). NEVER shutdown/occupy Pro Max.

## P1 config gaps（非施工门）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```

- 法律验收：本地法律页可加载；外链 gap `legal_url_unknown`  
- AI key 缺失：gap `ai_key_unavailable`；UL-03 验诚实未配置  
- CloudKit：gap `cloudkit_unconfigured`；本地持久化仍验收  
- 飞书行：gap `feishu_row_not_yet_created`（CONTROLLER_DELIVERY skip）  
- 禁止要求 Builder verify existing authorized configuration  

## Provider / consent

- Provider: DeepSeek  
- disclosure_version: rulecue.consent.v1  
- Fields before send: game_session_summary, component_map_summary, phase_steps_summary, setup_overlay_notes, current_zone_label, chat_text, voice_transcript, spoken_question  
- Opt-in before first send; Settings revoke immediate; provider policy + local privacy independent routes  

## Option A soft known_issues

Non-core UltraLite failures and P1 remote gaps must not block delivery; record as soft known_issues / Gaps.
