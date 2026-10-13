# STEER — DocBrief visual r2 (controller)

Hard stop before freeze:
- r1 frames were served from SnagCue local_seed (chrome shows SnagCue AI / Audits / Punch / walkthrough / snags).
- Do **not** freeze MAP.md or visual_manifest.v1.json on r1.
- Controller is regenerating DocBrief-semantic stems as `*-r2.png` via Cursor GenerateImage → drops → GrokBot batch, then re-running vision.
- New frame_ids: home-empty, capture-import, fields-review, brief-detail-filled, chat-extract, summary-card, tts-briefing, settings-privacy (all -r2).
- Only freeze after r2 readbacks are pass (or runtime_required uncertain).
