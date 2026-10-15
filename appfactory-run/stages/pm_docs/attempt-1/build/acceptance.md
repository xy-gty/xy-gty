# YarnCue — 验收映射

config_mode: local_only

privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

法律验收以**本地**隐私/协议/支持页可加载为准；外链列 gap，不是 UL-06 失败。禁止要求 Builder「verify existing authorized configuration」。

## 核心运行路径

| 路径 | 预期 |
|------|------|
| New project → Camera/Library → WIPShot 可见 | 权限对话框文案正确；取消可恢复 |
| StitchReview → Keep | StitchCue 持久；Discard 不写入 |
| ProjectCoach 见色卡条 + 横向下一行带 | 与设计帧语义一致 |
| Coach chat 首次 Send | 先出 Consent；拒绝仍可本地浏览步骤 |
| 同意后 Send（有 key）或诚实未配置（无 key） | 有 key：真实结果可审；无 key：`ai_key_unavailable` gap + 本地能力 |
| Turn Keep / Discard | 仅 Keep 写入 CoachMessage |
| AnnotatedWIP Keep marks | 叠加持久；拒绝保留原图 |
| Hands-free Play / Next | TTS 播报；步骤高亮 |
| Dictate / Speech | 文本进入备注或输入；拒权可手打 |
| Settings Revoke | 再 Send 被门拦住 |
| 重启 | Project/步骤/消息仍在 |

Simulator：iPhone 17 Pro ONLY。设备相机/麦克风可标 真机待测，入口仍须可达。

## 八域映射

| check_id | 本产品证明点 |
|----------|----------------|
| UL-01 | com.lingguang.yarncue 构建启动 |
| UL-02 | F1–F8 核心环端到端 |
| UL-03 | 真实 DeepSeek 或诚实未配置 + 本地烟测 |
| UL-04 | Keep 写入 / Discard 不写 / 重启一致 |
| UL-05 | 第二次调用带入已确认步骤与反馈 |
| UL-06 | 同意门、撤销、本地法律页、四权限文案与入口 |
| UL-07 | 色卡条+横向下一行带可读；无禁令孪生壳 |
| UL-08 | 证据绑定本 run 产品 commit |

## 权限

| Key | 验收关注 |
|-----|----------|
| NSCameraUsageDescription | Capture yarn / WIP photos for stitch & row recognition |
| NSPhotoLibraryUsageDescription | Import prior WIP / yarn shots into the coach flow |
| NSMicrophoneUsageDescription | Dictate pattern notes and row intent while knitting |
| NSSpeechRecognitionUsageDescription | Turn spoken next-row questions into coach chat and TTS |

## AI 同意

- Provider：DeepSeek  
- disclosure_version：yarncue.consent.v1  
- 字段：见 technical contract  
- 拒绝 / 设置撤销：保留本地 Project/步骤/标注  

## Gaps（非施工门）

- legal_url_unknown / ai_key_unavailable / cloudkit_unconfigured / feishu_row_not_yet_created  
- operator_pricing_deferred_free_app_only  
- Feishu delivery tracker：操作者要求 skip  

## review_controls

confirm: Keep  
reject: Discard  
edit: Edit
