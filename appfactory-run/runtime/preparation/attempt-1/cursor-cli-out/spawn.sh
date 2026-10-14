#!/bin/bash
cd /Users/a2026/work/factory-prod-1
OUT="runs/kf-20261014T073212Z-4039fa46/runtime/preparation/attempt-1/cursor-cli-out"
PROMPT="Dispatch 82c33e3d-bfa6-45df-85d7-7a3f66417839. Read /Users/a2026/work/factory-prod-1/runs/kf-20261014T073212Z-4039fa46/runtime/preparation/attempt-1/codex.launch.md SHA-256 4c345fa7b7122fb5c8cbe25533620cc9a4884dd4da70d8c800658407f7419b30. Verify the file hash, then execute that file. Do not copy the file into this message."
exec /Users/a2026/.local/bin/agent --model auto --print --force --trust --workspace /Users/a2026/work/factory-prod-1 --output-format text "$PROMPT" >> "$OUT/agent.stdout" 2>> "$OUT/agent.stderr"
