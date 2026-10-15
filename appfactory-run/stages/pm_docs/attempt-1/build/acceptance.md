# FrameCue — 验收说明

config_mode: local_only  
privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

法律验收以本地法律页可加载为准；外链 / AI key / CloudKit / 飞书行记 gap，不是施工门。禁止要求 Builder「verify existing authorized configuration」。`record_match_error=0` = 行尚未创建 = gap（本 run Feishu CONTROLLER_DELIVERY skip by operator）。

## 核心运行路径

| id | 路径 | 预期 |
|----|------|------|
| ACC-01 | 冷启动 → Sessions 空态 → New session | 非裸聊天；可见 New session；场记板轮廓/芯片条位置暗示 |
| ACC-02 | CaptureImport Camera 或 Photo library | 权限提示正确；得 FrameStill 或诚实拒绝 |
| ACC-03 | CompositionReview Keep / Discard / Edit | Keep 写 CompositionNote；Discard 不写 |
| ACC-04 | SlateStage 场记板画幅框 + 底部景别芯片切换 | 当前景别高亮；画幅框在场；非胶片齿孔/桌区卡/夜框轨 |
| ACC-05 | Coach chat → Consent → Send → TurnReview Keep | 同意前不发送；Keep 写 CoachMessage / 可更新 ShotSizePlan |
| ACC-06 | OverlayMarks Keep marks | AspectOverlay 绑定 FrameStill；重启仍在 |
| ACC-07 | Hands-free Play | TTS 播导演口令；芯片同步 |
| ACC-08 | Dictate shot-size | 语音意图写入教练输入并建议刷新叠图；权限拒绝诚实 |
| ACC-09 | Settings Revoke consent | 立即停发出站 |
| ACC-10 | 本地 Privacy / Terms / Support | 页可打开加载 |

## AI 验收行

| id | 检查 |
|----|------|
| ACC-AI-01 | 出站前 ConsentSheet 披露 DeepSeek + 字段；opt-in |
| ACC-AI-02 | Keep 后构图要点进入后续教练上下文（第二次调用可观测） |
| ACC-AI-03 | Discard 不持久构图 / 不写景别计划 |
| ACC-AI-04 | 无 key：诚实未配置；本地芯片/画幅框/叠图仍可用 |
| ACC-AI-05 | Revoke 后不再发送 |

## 八域映射

| check_id | 覆盖 |
|----------|------|
| UL-01 build_launch | FrameCue bundle `com.lingguang.framecue`；iPhone 17 Pro ONLY（prefer B14CC0EA；禁 Pro Max）启动 |
| UL-02 core_flows | ACC-01..08 全路径；空/错/取消可恢复 |
| UL-03 live_ai | 有 key 真出站；无 key → gap `ai_key_unavailable` + 本地烟测 |
| UL-04 reviewed_persistence | Keep/Discard/Edit；重启一致；CloudKit gap 不影响本地 |
| UL-05 feedback_reuse | ACC-AI-02 |
| UL-06 privacy_permissions | 四权限 + 同意/撤销 + 本地法律页；外链 gap |
| UL-07 ui_interaction | 对照 8 帧：场记板画幅框、底部景别芯片条、无全黑壳、无 RuleCue/StopCue/NightCue 孪生 |
| UL-08 repo_evidence | commit / 截图 / MAP 绑定本 attempt |

## 权限文案（Info.plist）

| Key | 文案 |
|-----|------|
| NSCameraUsageDescription | Capture on-set framing trial shots for composition coaching |
| NSPhotoLibraryUsageDescription | Import scout or reference stills for aspect and framing analysis |
| NSMicrophoneUsageDescription | Hands-free on-set director cues while both hands hold the camera |
| NSSpeechRecognitionUsageDescription | Spoken shot-size instructions written into coach chat and refresh overlays |

## Provider / legal

- Provider policy：应用内可达页面（本地）  
- 产品 Privacy / Terms / Support：本地页可加载；远程 URL UNKNOWN → gap `legal_url_unknown`  
- Feishu CONTROLLER_DELIVERY：skip → gap `feishu_row_skipped_by_operator`  

## Option A（非核心 UL）

非核心 UltraLite 失败按操作者 Option A 记 soft `known_issues`，P1 非阻断项不得挡交付；核心路径 ACC-01..10 / 四权限 / 独特 UI 仍须通过。
