# BendCoach AI — 验收映射

idea_source: operator_external  
config_mode: local_only  
privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

法律验收以**本地法律页可加载**为准；外链 UNKNOWN = gap，不是施工门。禁止要求 Builder「verify existing authorized configuration」。

## 核心运行路径

| ID | 路径 | 预期 |
|----|------|------|
| P-math | Home → Ask bend math →（consent）→ 答复含单位与 assistive 注 | 有 key：真实出站；无 key：诚实未配置 + 本地 demo |
| P-photo | CaptureImport → 相机或相册 → BendReview → Save | FieldPhoto+BendMarkup 持久；重启仍在 |
| P-reject | BendReview → Not this | 不写入 BendMarkup |
| P-diagram | JobDetail → Generate diagram → Use | DiagramOverlay 保存 |
| P-tts | JobDetail → Start coaching → Pause/Next | TTS 步骤可听/可见 |
| P-speech | BendMathChat → mic → STT → 可编辑发送 | 权限拒绝仍可键盘 |
| P-units | Settings → Units 切换 | 徽章与后续计算一致 |
| P-consent | 首次出站 ConsentSheet；Settings 撤销 | 撤销后停发 |

Simulator 不可测：嘈杂环境 TTS、部分相机硬件 → 真机待测，不挡交付。

## 八域映射

| check_id | 本产品证明点 |
|----------|----------------|
| UL-01 | Bundle `com.lingguang.bendcoach`；冷启 Home 可操作 |
| UL-02 | P-math→P-tts 核心售卖路径端到端；空/错/取消可恢复 |
| UL-03 | 有 key 真实 DeepSeek；无 key `ai_key_unavailable` gap + 本地 demo 烟测 |
| UL-04 | Save 才写；Not this/Discard 不写；重启一致；CloudKit gap 可接受 |
| UL-05 | 第二次 bend_math / recognize 带入已确认标记与反馈 |
| UL-06 | 同意前无发送；撤销停发；本地 Privacy/Terms/Support 可开；Provider policy 可达；外链 gap |
| UL-07 | 八帧对照：结构/CTA/单位徽章/assistive 注；无 QuickBend 品牌冒充 |
| UL-08 | 证据绑本 run product commit 与本 attempt 视觉/技术 hash |

## 权限

Camera / Photo Library / Microphone / Speech Recognition — Info.plist 用途字符串贴合 BendCoach；四条均可测（sim UI OK）。

## Provider / 披露

- Provider: DeepSeek  
- disclosure_version: bendcoach.consent.v1  
- 字段：chat_text, unit_system, field_photo_bytes, recognized_bend_type, markup_hints, coaching_context  

## Gaps（诚实）

- privacy_url / terms_url / support_url / ai_key / cloudkit: UNKNOWN  
- feishu_row_not_yet_created（local_only 预期）  
- operator_pricing_deferred_free_app_only（goal 付费解锁意图）  
- QuickBend 仅为品类参考，禁止品牌资产
