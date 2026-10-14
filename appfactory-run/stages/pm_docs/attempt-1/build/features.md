# ScoutCue — features.md

## 实体与关联

- ScoutShot 1—N SceneCard（识别草稿→确认）  
- SceneCard 1—1 ScoutPlan（窗口 + 备注）  
- ScoutPlan 1—N TimingWindow / OverlayMark / ShootNote / BriefingClip  
- CoachMessage（草稿）→ Keep → CoachTurn（历史）  
- AIConsentRecord（Keychain + 本地披露版本）

## 功能表

### F1 Capture / Import scenery

- 入口：ScoutsHome → Capture / Import  
- 操作：Camera 拍摄或 Photos 选图（PhotoImportSession）  
- 结果：新建 ScoutShot；进入 SceneReview  
- 持久：本地文件 + AtomicCodableStore  
- 空/错/取消：取消回 Home；解码失败保留空态提示  

### F2 Scene recognition → Scout card

- 入口：SceneReview  
- 操作：本地/AI 生成标签草稿；Edit labels；Keep / Discard  
- 结果：Keep → SceneCard + 默认 ScoutPlan；Discard 不写卡  
- AI：若出站开启，可 refinement；无 key 时本地启发式标签仍可 Keep  
- 第二次：历史卡标签进入后续 coach 上下文  

### F3 Sky-arc ephemeris timeline

- 入口：Home 与 ScoutCardDetail 顶部  
- 操作：横向浏览日升/黄金/蓝调/月出等窗；点选高亮  
- 结果：选中 TimingWindow 绑定当前计划  
- 持久：TimingWindow 列表  

### F4 Coach chat（sun/moon / golden-hour）

- 入口：ScoutCardDetail → Coach  
- 操作：提问 timing；同意门后发送；审阅回复 Keep / Discard  
- 发送字段：scene_labels、shot_meta、plan_windows、user_chat_text  
- 持久：仅 Keep 写入 CoachTurn；反馈进入下次调用  
- 无 key：诚实未配置，本地窗口说明仍可读  

### F5 Golden-hour overlay annotations

- 入口：ScoutCardDetail → Overlay  
- 操作：在风景图上点按添加软标注（文案+相对坐标）；Save / Discard  
- 结果：OverlayMark 列表；**不是**测距尺或绳路径轮播  
- 持久：随 ScoutPlan  

### F6 TTS next-stop briefing

- 入口：Next stop  
- 操作：Play / Pause / Next（AVSpeechSynthesizer）播报 BriefingClip  
- 结果：可听下一站构图/窗口提示；可从计划字段生成队列  
- 错态：空队列提示先完成卡/窗口  

### F7 Dictate shoot notes

- 入口：Dictate  
- 操作：麦克风 + Speech → 转写进 ShootNote / plan note  
- 取消：不写；拒绝权限保留其它本地能力  
- Simulator：入口可测；真机录音可标 真机待测  

### F8 Settings / consent / legal

- 同意前无出站；撤销立即停发  
- 本地 Privacy / Terms / Support 页可加载  
- Provider policy 独立可达  
- 外链 URL：UNKNOWN gap  

## 错误 / 取消 / 空态 / 重启

- Home 空态：天空弧今日示意 +「Capture or import your first scout」  
- AI 失败：错误条 + 保留本地卡/窗口  
- 重启：ScoutShot / SceneCard / Plan / Turns / Notes / Marks 可读回  
- 第二次 AI：带入已 Keep 的标签、窗口、备注与上轮反馈  

## review_controls

confirm: Keep · reject: Discard · edit: Edit labels
