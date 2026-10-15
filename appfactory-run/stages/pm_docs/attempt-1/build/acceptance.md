# HiveCue — 验收说明

config_mode: local_only  
privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

法律验收以本地法律页可加载为准；外链 / AI key / CloudKit / 飞书行记 gap，不是施工门。禁止要求 Builder「verify existing authorized configuration」。`record_match_error=0` = 行尚未创建 = gap（本 run Feishu skip by operator）。

## 核心运行路径

| id | 路径 | 预期 |
|----|------|------|
| ACC-01 | 冷启动 → Inspections 空态 → New inspection | 非裸聊天；可见 New inspection |
| ACC-02 | CaptureImport Camera 或 Photo library | 权限提示正确；得 FrameShot 或诚实拒绝 |
| ACC-03 | BroodReview Keep / Discard / Edit | Keep 写 Finding；Discard 不写 |
| ACC-04 | InspectionCoach 蜂巢网格切换 + InspectionRail | 当前脾位高亮；轨显示下一动作 |
| ACC-05 | Coach chat → Consent → Send → TurnReview Keep | 同意前不发送；Keep 写 CoachMessage |
| ACC-06 | AnnotatedFrame Keep marks | AnnotatedOverlay 绑定 FrameShot；重启仍在 |
| ACC-07 | Hands-free Play | TTS 播 Finding/笔记；轨/网格同步 |
| ACC-08 | Dictate inspection fields | 语音写入 DictatedField；权限拒绝诚实 |
| ACC-09 | Settings Revoke consent | 立即停发出站 |
| ACC-10 | 本地 Privacy / Terms / Support | 页可打开加载 |

## AI 验收行

| id | 检查 |
|----|------|
| ACC-AI-01 | 出站前 ConsentSheet 披露 DeepSeek + 字段；opt-in |
| ACC-AI-02 | Keep 后 Finding 进入后续教练上下文（第二次调用可观测） |
| ACC-AI-03 | Discard 不持久 Finding / 不写计划 |
| ACC-AI-04 | 无 key：诚实未配置；本地网格/轨/标注仍可用 |
| ACC-AI-05 | Revoke 后不再发送 |

## 八域映射

| check_id | 覆盖 |
|----------|------|
| UL-01 build_launch | HiveCue bundle `com.lingguang.hivecue`；iPhone 17 Pro 启动 |
| UL-02 core_flows | ACC-01..08 全路径；空/错/取消可恢复 |
| UL-03 live_ai | 有 key 真出站；无 key → gap `ai_key_unavailable` + 本地烟测 |
| UL-04 reviewed_persistence | Keep/Discard/Edit；重启一致；CloudKit gap 不影响本地 |
| UL-05 feedback_reuse | ACC-AI-02 |
| UL-06 privacy_permissions | 四权限 + 同意/撤销 + 本地法律页；外链 gap |
| UL-07 ui_interaction | 对照 8 帧：蜂巢网格、巡检轨、热力叠图、无全黑壳、无孪生布局 |
| UL-08 repo_evidence | commit / 截图 / MAP 绑定本 attempt |

## 权限文案（Info.plist）

| Key | 文案 |
|-----|------|
| NSCameraUsageDescription | Capture brood-frame photos for AI hive inspection |
| NSPhotoLibraryUsageDescription | Import past frame photos to compare brood / stores / pests |
| NSMicrophoneUsageDescription | Hands-free inspection notes while suited and gloved |
| NSSpeechRecognitionUsageDescription | Dictate inspection fields (queen seen, temperament, notes) into the log |

## Provider / legal

- Provider policy：应用内可达页（产品实现）  
- 本产品 privacy/terms/support：本地页必达；外链 UNKNOWN  
- 发送字段见 technical contract `hivecue.consent.v1`

## Gaps（交付前）

- privacy_url / terms_url / support_url / ai_key / cloudkit：UNKNOWN  
- feishu_row_skipped_by_operator  
- operator_pricing_deferred_free_app_only（one-time unlock / apiary packs 未实现）  
- 真机相机/麦克风：Simulator 可标 真机待测  
