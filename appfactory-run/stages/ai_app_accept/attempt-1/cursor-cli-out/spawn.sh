#!/bin/bash
cd /Users/a2026/work/factory-prod-1
OUT="runs/kf-20261014T073212Z-4039fa46/stages/ai_app_accept/attempt-1/cursor-cli-out"
PROMPT="Dispatch 5d398972-e53d-4efd-98f2-8a3d730cbc3e. Read /Users/a2026/work/factory-prod-1/runs/kf-20261014T073212Z-4039fa46/stages/ai_app_accept/attempt-1/codex.launch.md SHA-256 b52ef737e292a681592b2b5055487b2ddb0df9ce4399a0aec3a7c25ee421e24c. Verify the file hash, then execute that file. Do not copy the file into this message."
exec /Users/a2026/.local/bin/agent --model auto --print --force --trust --workspace /Users/a2026/work/factory-prod-1 --output-format text "$PROMPT" >> "$OUT/agent.stdout" 2>> "$OUT/agent.stderr"
