# PitchCue — 验收说明

config_mode: local_only

privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

法律验收以应用内本地 Privacy / Terms / Support 页可加载为准；外链 URL 为 gap，不是 UL-06 失败。  
禁止要求 Builder「verify existing authorized configuration」。飞书交付行操作者 skip。

## 运行路径

### A. 导入与会话

1. 冷启动 → Home empty → New practice  
2. Camera 或 Photo library 导入一张乐谱图 → 会话创建  
预期：SheetPhoto 可见；取消不建脏会话

### B. AI 计划人审

1. Coach chat 输入目标 → 首次出站前 ConsentSheet 披露 DeepSeek + 字段  
2. 拒绝同意 → 仅本地；允许后发送  
3. 草稿出现 → Keep / Discard / Edit  
预期：仅 Keep 写入 PracticePlan；Discard 不持久；Edit 后再 Keep 覆盖

### C. 练习地板

1. Count-in TTS 可听  
2. 启动 metronome 或 drone → 连续波形可见  
3. 水平练习条可切换步骤  
预期：无 CuePartner timeline；无全黑壳

### D. 可选音高

1. Pitch check → 麦克风权限  
2. 圆形调音盘显示偏差  
预期：拒绝权限后计划/TTS/drone 仍可用

### E. 反馈复用与重启

1. Keep 计划后杀进程重启 → 计划仍在  
2. 第二次 Ask coach 带入已确认步骤与反馈  
预期：上下文可观测差异；无 key 时诚实未配置

### F. 隐私

1. 同意前无出站网络意图  
2. Settings 撤销后停发  
3. 本地法律页与 Provider policy 可打开

## 八域映射

| check_id | 本产品关注点 |
|----------|----------------|
| UL-01 | iPhone 17 Pro 构建启动；bundle `com.lingguang.pitchcue` |
| UL-02 | 导入→计划→TTS→audio bed→可选 pitch 全路径 |
| UL-03 | 真实 DeepSeek 或诚实未配置；consent 后才发 |
| UL-04 | Keep 才写；Discard 不写；重启一致 |
| UL-05 | 第二次调用复用已确认计划/反馈 |
| UL-06 | 同意/拒绝/撤销；本地法律页；四权限文案 |
| UL-07 | 七帧结构还原；练习条/波形/圆形盘可读 |
| UL-08 | 证据绑本 run commit 与视觉 hash |

## 权限

| Key | 验收 |
|-----|------|
| NSCameraUsageDescription | 文案存在；入口可达（真机拍摄可 真机待测） |
| NSPhotoLibraryUsageDescription | Simulator 可测导入 |
| NSMicrophoneUsageDescription | 入口可达；拒绝保留本地练习 |
| NSSpeechRecognitionUsageDescription | 口语目标入口可达 |

## Provider / 同意

- Provider: DeepSeek  
- disclosure_version: pitchcue.consent.v1  
- 字段见 technical contract  
- confirm: Keep / reject: Discard / edit: Edit

## Gaps（非施工门）

- legal_url_unknown / ai_key_unavailable / cloudkit_unconfigured  
- feishu_row_not_yet_created（操作者 skip tracker）  
- operator_pricing_deferred_free_app_only  
- branding_assets_deferred（无 AppIcon/splash 本轮）  
- camera/mic 长硬件路径：真机待测 where needed
