# HiveCue — 功能说明

confirm: Keep  
reject: Discard  
edit: Edit

## F1 巡检架（InspectionsHome）

- 入口：冷启动 / Tab Inspections  
- 操作：浏览 Inspection 列表；空态主 CTA「New inspection」  
- 结果：进入 NewInspection 或已有 InspectionCoach  
- 持久：Inspection 列表 AtomicCodableStore  
- 空态：空架 + 六边形蜂巢网格位置暗示巡检产品（非裸聊天壳）  
- 错误：存储损坏 → 保留旧文件 + 字面恢复失败提示  

## F2 新建巡检 + 拍/导入巢脾

- 入口：New inspection → CaptureImport  
- 操作：Camera 拍巢脾 / Photo library 导入历史对照帧  
- 结果：FrameShot 落盘 → 自动进入 BroodReview（若 AI 可用则生成草稿，否则本地占位草稿可 Edit）  
- 权限：Camera / Photos；拒绝时诚实提示，保留相册或稍后重试  
- Simulator：入口可测；真机相机可标 真机待测  

## F3 巢脾识别审阅（BroodReview）

- 入口：Capture 成功后  
- 操作：阅读 brood / stores / pest 要点；Keep / Discard / Edit  
- 结果：Keep → Finding + 可选进入 InspectionCoach；Discard → 不写 Finding；Edit → 改文案后再 Keep  
- AI：读取 frame_photo_descriptor；结构化识别要点；人审前不写 Finding  
- 等待：Progress + Cancel；失败横幅 + Retry  
- 重启：未确认草稿可恢复；已 Keep 的 Finding 在 InspectionCoach 可见  

## F4 InspectionCoach（蜂巢网格 + 巡检轨 + 热力叠图）

- 入口：审阅 Keep 后或打开已有 Inspection  
- 操作：HexCombGrid 选脾位；InspectionRail 推进当前帧；热力叠图打开 AnnotatedFrame；Ask coach / Hands-free / Dictate  
- 结果：当前脾位高亮；轨道显示下一动作提示  
- 持久：脾位序列与当前索引、Finding 绑定  
- 独特 UI：六边形蜂巢网格、巡检轨、热力叠图（硬）  

## F5 教练聊天下一步

- 入口：InspectionCoach → Ask coach  
- 操作：文字发送「下一步」/改计划；同意门首次拦截  
- AI：读取 brood_summary、stores_summary、pest_signs、inspection_plan_summary、current_frame_label、chat_text；产出 CoachTurn  
- 人审：TurnReview Keep → CoachMessage；Discard 不写  
- 第二次调用：带入已 Keep 的 Finding 与反馈  
- 无 key：诚实未配置 / 出站关闭，本地仍可手改网格与字段  

## F6 热力 / 区域叠图（AnnotatedFrame）

- 入口：InspectionCoach 热力叠图入口  
- 操作：在 FrameShot 上查看/确认 AI 建议热区；Keep marks / Discard  
- 结果：AnnotatedOverlay 确认态绑定该 FrameShot  
- 空态：无照片时引导回 Capture  

## F7 TTS 免提巡检笔记

- 入口：Hands-free  
- 操作：Play / Pause / Next；朗读当前 Finding / VoiceNote  
- 结果：InspectionRail 与网格同步高亮；播放指示可见  
- 场景：穿蜂衣、双手戴手套时听笔记  

## F8 口述巡检字段（DictateFields）

- 入口：Dictate / 麦克风  
- 操作：说话写入 queen seen / temperament / notes → Speech → DictatedField  
- 结果：字段写入当前 Inspection；可填入教练输入；权限拒绝诚实提示  
- 权限：Microphone + Speech Recognition  

## F9 同意与设置

- ConsentSheet：披露 DeepSeek、字段列表、opt-in；拒绝保留本地  
- Settings：Revoke AI consent 立即停发；本地 Privacy / Terms / Support 页可加载  
- 外链 URL：UNKNOWN gap  
- 四权限 Info.plist 文案与可测入口必须齐全  

## 实体关系（摘要）

Inspection 1—* FrameShot；FrameShot 0..1 Finding；FrameShot 0..* AnnotatedOverlay；Inspection 1—* CoachMessage；CoachTurn 审阅后变 CoachMessage；VoiceNote / DictatedField 附着 Inspection。

## 通知底座（记录类）

巡检含时间序列事件：本地通知可选「下次开箱提醒」+ Settings 开关；首次成功 Keep Finding 后或用户打开开关时才请求通知权限（不怼脸）。
