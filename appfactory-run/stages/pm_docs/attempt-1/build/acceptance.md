# NightCue — 验收说明

config_mode: local_only  
confirm: Keep · reject: Discard · edit: Edit

## 运行路径与预期

| ID | 路径 | 预期 |
|----|------|------|
| P1 | 冷启动 → Sessions 空态 | 见夜拍架空态 + New session；非裸聊天 |
| P2 | New session → Camera 或 Photos | 权限弹窗或诚实拒绝态；成功得到 NightFrame |
| P3 | ExposureReview → Keep | DiagnosisFinding 持久；进入 NightCoach |
| P4 | NightCoach 帧轨切换 + 叠层开关 | 当前帧与 exposure-diagnosis overlay 可见 |
| P5 | Ask coach → Consent → Send → Keep | 有 key 时真实出站；无 key 时诚实未配置 |
| P6 | Annotated overlay → Keep marks | AnnotatedOverlay 绑定帧 |
| P7 | Field cues → Play | TTS 朗读口令（Simulator 可听） |
| P8 | Dictate → Record → Save | Mic+Speech；字段写入 DictatedExposure |
| P9 | Settings Revoke + 本地法律页 | 同意撤销；Privacy/Terms/Support 本地可加载 |

## 八域映射（UltraLite）

| 域 | 本产品焦点 | 备注 |
|----|------------|------|
| UL-01 核心循环 | P1–P4 | 夜景帧轨 + 诊断叠层必须可见 |
| UL-02 持久与恢复 | Session/Frame/Finding 重启仍在 | AtomicCodableStore |
| UL-03 AI | Consent + 出站或诚实未配置 | 本地规则诊断可作 smoke |
| UL-04 人审 | Keep/Discard/Edit | 按钮名冻结 |
| UL-05 权限 | Camera/Photos/Mic/Speech | 真机待测可 Option A soft |
| UL-06 法律 | 本地页可加载 | 外链 UNKNOWN gap |
| UL-07 视觉 | 对照 8 帧 + 运行截图 | 不要求像素一致 |
| UL-08 交付身份 | nightcue/ + bundle + 独立分支 | Feishu skip |

## 权限与隐私

| 权限 | 可测入口 | Info.plist |
|------|----------|------------|
| Camera | Capture | NSCameraUsageDescription: Capture night test frames for AI long-exposure coaching |
| Photos | Import | NSPhotoLibraryUsageDescription: Import past night frames to compare exposure and noise |
| Microphone | Dictate / hands-free Q&A | NSMicrophoneUsageDescription: Hands-free parameter Q&A while holding a tripod |
| Speech | Dictate exposure | NSSpeechRecognitionUsageDescription: Dictate exposure settings (ISO, shutter, aperture, notes) into the coach |

## AI 发送前授权

- Provider: DeepSeek  
- disclosure_version: nightcue.consent.v1  
- 字段：frame_photo_descriptor、exposure_summary、noise_summary、trail_signs、scene_plan_summary、current_frame_label、chat_text、voice_transcript、dictated_exposure_fields  
- 拒绝/撤销：不得出站；Settings 可撤销  

## 远程配置（P1 gaps，非施工门）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```

禁止指示 Builder「verify existing authorized configuration」。  
法律验收以本地法律页可加载为准。  
`record_match_error=0` = feishu_row_not_yet_created gap（CONTROLLER_DELIVERY skip）。  
Stage stuck → Option A soft known_issues；P1 non-blockers must not block delivery。

## Simulator 锁

iPhone 17 Pro ONLY（prefer B14CC0EA）。NEVER shutdown/occupy Pro Max（315A7C2C 等）。
