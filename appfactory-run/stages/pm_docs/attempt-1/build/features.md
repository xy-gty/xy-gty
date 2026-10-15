# FrameCue — 功能说明

confirm: Keep  
reject: Discard  
edit: Edit

## F1 会话架（SessionsHome）

- 入口：冷启动 / Tab Sessions  
- 操作：浏览 FramingSession 列表；空态主 CTA「New session」  
- 结果：进入 NewSession 或已有 SlateStage  
- 持久：FramingSession 列表 AtomicCodableStore  
- 空态：空架 + 场记板画幅框轮廓预留 + 底部景别芯片条位置暗示（非裸聊天壳；非胶片齿孔时间线；非桌区卡）  
- 错误：存储损坏 → 保留旧文件 + 字面恢复失败提示  

## F2 新建会话 + 拍/导入静帧

- 入口：New session → CaptureImport  
- 操作：Camera 拍片场试拍 / Photo library 导入勘景或参考静帧  
- 结果：FrameStill 落盘 → 自动进入 CompositionReview（若 AI 可用则生成草稿，否则本地占位草稿可 Edit）  
- 权限：Camera / Photos；拒绝时诚实提示，保留相册或稍后重试  
- Simulator：入口可测；真机相机可标 真机待测  

## F3 构图问题审阅（CompositionReview）

- 入口：Capture 成功后  
- 操作：阅读构图要点（主体偏移、边缘切人、留白、对称）；Keep / Discard / Edit  
- 结果：Keep → CompositionNote + 可选进入 SlateStage；Discard → 不写；Edit → 改文案后再 Keep  
- AI：读取 still_descriptor；结构化构图要点；人审前不写 CompositionNote  
- 等待：Progress + Cancel；失败横幅 + Retry  
- 重启：未确认草稿可恢复；已 Keep 的要点在 SlateStage 可见  

## F4 SlateStage（场记板画幅框 + 底部景别芯片条）

- 入口：审阅 Keep 后或打开已有 Session  
- 操作：底部 ShotSizeChipBar 切换 ECU/CU/MS/WS/EWS；ClapperFrameCanvas 内看当前静帧；打开 OverlayMarks / Ask coach / Hands-free / Dictate  
- 结果：当前 ShotSizePlan 高亮；画幅框随景别语义更新提示  
- 持久：ShotSizePlan 与当前索引  
- 独特 UI：片场场记板式画幅框 + 底部景别芯片条（硬；禁 RuleCue/StopCue/NightCue 孪生）  

## F5 教练聊天景别 / 画幅 / 焦段

- 入口：SlateStage → Ask coach  
- 操作：文字发送景别/画幅比/焦段语言；同意门首次拦截  
- AI：读取 composition_summary、shot_size_label、aspect_ratio_label、lens_language、chat_text；产出 CoachTurn  
- 人审：TurnReview Keep → CoachMessage + 可写回 ShotSizePlan / Overlay 建议；Discard 不写  
- 第二次调用：带入已 Keep 的构图要点与景别反馈  
- 无 key：诚实未配置 / 出站关闭，本地仍可手改芯片条与叠图  

## F6 安全框 / 三分法叠图（OverlayMarks）

- 入口：SlateStage → Overlays  
- 操作：在 FrameStill 上查看/确认 safe-frame、rule-of-thirds、aspect 叠层；Keep marks / Discard  
- 结果：AspectOverlay 确认态绑定该 FrameStill  
- 空态：无照片时引导回 Capture  

## F7 TTS 免提现场口令

- 入口：Hands-free  
- 操作：Play / Pause / Next；按当前景别与叠图焦点朗读导演口令（如 “Hold medium shot, watch left edge”）  
- 结果：HandsFreeTTSPlayer 播报；芯片高亮同步  
- 无网络可本地 TTS  

## F8 口述景别（DictateShot）

- 入口：Dictate  
- 操作：麦克风录音 → Speech Recognition 转写景别指令（如 “switch to medium shot”）→ 写入教练输入并触发叠图刷新建议  
- 权限：Microphone / Speech；拒绝诚实提示  
- 持久：VoiceIntent；确认后可进 CoachTurn 流程  
- Simulator：入口与权限文案可测；真机识别可标 真机待测  

## F9 Settings / 同意 / 法律

- 入口：Tab Settings  
- 操作：Revoke AI consent；查看四权限用途文案；打开本地 Privacy / Terms / Support  
- 结果：撤销后立即停发出站；本地法律页可加载  
- 外链 URL：UNKNOWN gap  

## AI 合同摘要

| 项 | 值 |
|----|-----|
| Provider | DeepSeek |
| disclosure_version | framecue.consent.v1 |
| 发送字段 | still_descriptor, composition_summary, shot_size_label, aspect_ratio_label, lens_language, overlay_focus, chat_text, voice_transcript |
| 人审 | Keep / Discard / Edit（TurnReview 无 Edit 时仅 Keep/Discard） |
| 持久 | 仅确认后写 CompositionNote / CoachMessage / AspectOverlay |
| 反馈复用 | 第二次调用带入已 Keep 要点与景别计划 |
