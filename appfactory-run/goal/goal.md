# Run objective

# StopCue

Paid AI stop-motion coach (one-time unlock for unlimited projects; no coins).

Remake vs Stop Motion Studio Pro (com.cateater.funapps.stopmotionstudiopro).

## Core loop
Capture or import frame sequences → chat for shot plans and timing → generate onion-skin annotated guides → TTS countdown cues → dictate interval/cue edits into coach.

## Hard operator rules
- product_dir: stopcue/ (never leave as product/ only — symlink stopcue→product)
- palette: primary #16A34A · secondary #F0FDF4 · accent #DB2777 (must differ from NightCue #1E3A8A and other delivered apps; ban all-black clones)
- UI: film-sprocket timeline (胶片齿孔时间轴) + onion-skin overlay preview (洋葱皮叠层预览); must look clearly different from NightCue night-frame rail, CuePartner script axis, HiveCue/FormCue/YarnCue/ScoutCue (no twins)
- Four permissions with real flows (extend core, do not replace):
  - Camera: frame-by-frame capture for stop-motion sequences
  - Photos: import frame sequences into the coach timeline
  - Microphone: hands-free interval/cue edits while shooting
  - Speech Recognition: e.g. "next frame a bit closer" written into storyboard coach
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max (UDID 315A7C2C or any Pro Max) even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery
- When disk tight: clear unused DerivedData/simulator caches proactively (never touch in-use DerivedData)

## Idea
Build a paid AI stop-motion coach: capture or import frame sequences, chat for shot plans and timing, generate onion-skin annotated guides, TTS countdown cues—unlock unlimited projects.

## Positioning
AI 定格动画教练——逐帧拍/导入，对话分镜与间隔，洋葱皮标注叠图，TTS 倒计时口令；胶片齿孔时间轴 + 洋葱皮叠层预览。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
