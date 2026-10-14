#!/bin/bash
cd /Users/a2026/work/factory-prod-1
OUT="runs/kf-20261014T091741Z-3d7b568c/stages/pm_docs/attempt-1/cursor-cli-out"
PROMPT="Dispatch a4b687aa-f874-48ff-a831-ec93fb02eab5. Read /Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/stages/pm_docs/attempt-1/codex.launch.md SHA-256 4d4eb9c0ac90d72205cabb47ff5c0f4b5a3d265c86b14cb6e23c304033dde80f. Verify the file hash, then execute that file. Do not copy the file into this message."
exec /Users/a2026/.local/bin/agent --model auto --print --force --trust --workspace /Users/a2026/work/factory-prod-1 --output-format text "$PROMPT" >> "$OUT/agent.stdout" 2>> "$OUT/agent.stderr"
