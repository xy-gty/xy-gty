# CuePartner AI — 验收说明

config_mode: local_only  
privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

法律验收以**本地** Privacy / Terms / Support 页可加载为准；外链 URL 为 gap，不是 UL-06 失败。禁止要求 Builder「verify existing authorized configuration」。

## 核心运行路径

| 路径 | 预期 |
|------|------|
| New scene → Photo library 导入 → OCR → Keep | ScriptPage 持久；SceneDetail 可见文本 |
| Camera 入口 | 权限文案 CuePartner 专属；Simulator 可走入口（真机拍摄可 真机待测） |
| Partner chat → Consent → Send → Keep | RehearsalMessage 写入；Discard 不写；重启仍在 |
| 无 AI key | 诚实未配置；本地导入/TTS/Voice note UI 仍可用 |
| Cue rehearsal Play | 高亮当前行 + TTS + pause_ms 停顿 |
| Ambience On/Off | 音床可开关且不阻断 TTS |
| Voice note / Speak line | 麦克风与 Speech 权限文案正确；拒绝后仍可打字 |
| Settings Revoke | 撤销后再次 Send 被门拦截 |
| 本地法律页 | Privacy/Terms/Support 可打开 |

## 八域映射

| check_id | 本产品证明点 |
|----------|--------------|
| UL-01 | com.lingguang.cuepartner 构建启动，Scenes 可操作 |
| UL-02 | 导入→OCR→对戏→TTS→音床/Voice 入口完整；空/错/取消可恢复 |
| UL-03 | 有 key 时真实 DeepSeek 对戏；无 key 时诚实关闭 + 本地烟测 |
| UL-04 | Keep 才写入；Discard 不写；重启一致 |
| UL-05 | 第二次对戏带入已确认历史 |
| UL-06 | 同意前不发送；撤销停发；本地法律页；四项隐私用途文案；外链 UNKNOWN=gap |
| UL-07 | 对照 8 帧结构/CTA/导航；首次体验完成导入+审阅 |
| UL-08 | 证据绑定产品 commit 与本 attempt |

## 权限与 AI 披露

- Camera / Photo Library / Microphone / Speech Recognition：Info.plist 应用专属英文文案（见 technical/contract.md）  
- 发送前披露 Provider=DeepSeek、字段列表、disclosure_version=`cuepartner.consent.v1`  
- Provider policy 与本地 privacy 为独立可达页  

## Provider-policy / legal 来源

- 应用内本地 HTML/Markdown 页（Builder 打包）  
- 远程 privacy/terms/support URL：UNKNOWN → gap `legal_url_unknown`  
- 飞书行：预期 `feishu_row_not_yet_created` gap  

## Simulator vs 真机

- Simulator：导入入口、OCR 旅程（可用相册样例图）、对戏 UI、TTS、音床、权限文案旅程  
- 真机待测：真实相机连拍、长时麦克风录音质量（入口仍须存在）

## 非本交付

- StoreKit unlock / 付费墙 → gap `operator_pricing_deferred_free_app_only`  
- CloudKit → gap `cloudkit_unconfigured`  
- AI key 缺失 → gap `ai_key_unavailable`（不因此 blocked 整包，若本地路径诚实）
