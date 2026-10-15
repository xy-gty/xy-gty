# StopCue — 验收合同

idea_source: operator_external  
config_mode: local_only

## Runtime paths（核心）

| ID | Path | Expected |
|----|------|----------|
| ACC-01 | New project → CaptureImport Camera | FrameSequence gains frames; cancel leaves prior intact |
| ACC-02 | CaptureImport Photos import | Sequence imported; Photos deny → honest banner + manual empty |
| ACC-03 | FrameReview Keep/Discard/Edit | Keep writes TimingCue; Discard no write; Edit revises draft |
| ACC-04 | StopCoach film-sprocket + onion toggle | Timeline selects frame; onion overlay visible; restart restores route |
| ACC-05 | CoachChat + consent + TurnReview | No send before consent; Keep persists CoachMessage; Discard no write |
| ACC-06 | OnionSkinGuide Keep | OnionSkinGuide persisted and shown on next frame |
| ACC-07 | CountdownTTS Play | AVSpeech plays countdown; Pause/Next work; failure text shown |
| ACC-08 | DictateInterval speech | DictatedInterval fields written; mic/speech deny → manual fields remain |
| ACC-09 | Settings revoke consent | Outbound stops immediately; local capture still works |
| ACC-AI-01 | Live DeepSeek with key | Real request/response bound to Project context |
| ACC-AI-02 | No key / local_only | Honest not-configured; consent still blocks send |

## Eight domains mapping

| Domain | Coverage |
|--------|----------|
| UL-01 build_launch | com.lingguang.stopcue on iPhone 17 Pro (B14CC0EA); launch ProjectsHome |
| UL-02 core_flows | ACC-01..09 |
| UL-03 live_ai | ACC-AI-01 or ACC-AI-02 + gap `ai_key_unavailable` |
| UL-04 reviewed_persistence | Keep writes; Discard no write; restart consistent |
| UL-05 feedback_reuse | Second coach call includes confirmed TimingCue/OnionSkinGuide/CoachMessage |
| UL-06 privacy_permissions | Camera/Photos/Mic/Speech real prompts; consent gate; local legal pages load; revoke stops send |
| UL-07 ui_interaction | Frames vs runtime screenshots for film-sprocket + onion-skin; no twin chrome |
| UL-08 repo_evidence | product commit + MAP refs; stopcue/ dir symlink rule |

## Permissions（必测）

| Permission | Flow |
|------------|------|
| Camera | Frame-by-frame capture for stop-motion sequences |
| Photos | Import frame sequences into coach timeline |
| Microphone | Hands-free interval/cue edits while shooting |
| Speech Recognition | Dictate e.g. “next frame a bit closer” into storyboard coach |

## AI consent

- Provider: DeepSeek  
- Disclosure version: `stopcue.consent.v1`  
- Fields: frame_sequence_descriptor, shot_plan_summary, timing_summary, onion_skin_notes, current_frame_label, chat_text, voice_transcript, dictated_interval_fields  
- Opt-in before first send; Settings revoke; provider policy + local privacy pages reachable  

## P1 config gaps（非施工门）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
feishu_row_not_yet_created
```

法律验收以**本地法律页可加载**为准；外链 / CloudKit / AI key / 飞书行列 gap，Delivery `replace_before_submission`。禁止要求 Builder verify existing authorized configuration。

## Simulator lock

- iPhone 17 Pro ONLY prefer B14CC0EA  
- NEVER shutdown/occupy Pro Max (315A7C2C or any Pro Max)  
- Device camera/mic/speech may mark 真机待测; Simulator still exercises journey entry points  
