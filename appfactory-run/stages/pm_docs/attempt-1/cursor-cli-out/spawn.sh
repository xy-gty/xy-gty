#!/bin/bash
cd /Users/a2026/work/factory-prod-1
OUT="runs/kf-20261014T073212Z-4039fa46/stages/pm_docs/attempt-1/cursor-cli-out"
PROMPT="Dispatch c8ca2d4f-e11c-4b15-9411-2a9f77ebc775. Read /Users/a2026/work/factory-prod-1/runs/kf-20261014T073212Z-4039fa46/stages/pm_docs/attempt-1/codex.launch.md SHA-256 875b3b96364ba1c8c658ce85f2c0424f226858c972b89124f9cb299ac1d57a66. Verify the file hash, then execute that file. Do not copy the file into this message."
exec /Users/a2026/.local/bin/agent \
  --model auto \
  --print \
  --force \
  --trust \
  --workspace /Users/a2026/work/factory-prod-1 \
  --output-format text \
  "$PROMPT" \
  >> "$OUT/agent.stdout" 2>> "$OUT/agent.stderr"
