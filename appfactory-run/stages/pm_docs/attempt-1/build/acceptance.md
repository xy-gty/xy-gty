# SnagCue AI — 验收说明

config_mode: local_only  
privacy_url: UNKNOWN  
terms_url: UNKNOWN  
support_url: UNKNOWN  
ai_key: UNKNOWN  
cloudkit: UNKNOWN

## 核心运行路径

1. **新建 Audit + 导入照片**：Start audit → 导入 ≥1 张 → Home/Active 可见 Audit。  
2. **Snag 审阅**：Detect → Save 一条 → PunchItem 出现；Not this 不写入。  
3. **聊天补字段**：Chat fill → 同意（若首次）→ 得提议 → Save 后字段更新；重启仍在。  
4. **第二次 AI**：带已确认字段/反馈再问，上下文可见适配（或无 key 时诚实未配置）。  
5. **标注报告**：Generate → Use 持久 / Discard 不写；无 key = 未配置态。  
6. **TTS**：Read aloud 播报当前项，Next 切换。  
7. **隐私**：同意前无出站；撤销后停发；本地 Privacy/Terms/Support 可打开；Provider policy 可达。

## 八域映射

| check_id | 本产品证明点 |
|----------|--------------|
| UL-01 | com.lingguang.snagcue 构建启动，Audits 可操作 |
| UL-02 | F1–F5 端到端；空/错/取消可恢复 |
| UL-03 | 有 key 真实 DeepSeek；无 key = `ai_key_unavailable` gap + 诚实关闭；本地导入/手写/TTS 仍烟测 |
| UL-04 | Save 才写 PunchItem；Reject 不写；重启一致；CloudKit UNKNOWN = gap |
| UL-05 | 第二次聊天带入已确认结果/反馈 |
| UL-06 | ConsentGate；撤销停发；本地法律页；外链 URL gap |
| UL-07 | 对照 8 帧结构/CTA/导航；键盘不挡 Chat |
| UL-08 | 证据绑本 run 产品 commit 与 visual_manifest hash |

## 权限

- Photo Library / Camera：仅导入 walkthrough 照片时申请  
- Speech 合成：系统 TTS，无需麦克风（本交付不强制 STT）  
- 不申请 ATT

## AI 授权设计

- 发送前主动同意；披露接收方 DeepSeek 与字段：walkthrough_photo_bytes、punch_item_fields、chat_text、snag_labels  
- 拒绝保留本地导入/手写 punch/TTS  
- Settings 撤销立即停发  
- Provider policy 与本地 privacy 独立入口

## Gaps（非施工门）

- legal_url_unknown / ai_key_unavailable / cloudkit_unconfigured / feishu_row_not_yet_created  
- operator_pricing_deferred_free_app_only  
- 真机 TTS 音量/后台音频若 Simulator 不足 → known_issues 真机待测
