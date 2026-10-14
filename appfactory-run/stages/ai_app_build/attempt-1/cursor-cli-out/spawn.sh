#!/bin/bash
cd /Users/a2026/work/factory-prod-1
OUT="runs/kf-20261014T073212Z-4039fa46/stages/ai_app_build/attempt-1/cursor-cli-out"
PROMPT="Dispatch 4179ae95-b51f-429c-859c-5eb174b28771. Read /Users/a2026/work/factory-prod-1/runs/kf-20261014T073212Z-4039fa46/stages/ai_app_build/attempt-1/codex.launch.md SHA-256 4709fea93f5ffb3a871ab12761e70f2cbda8eb760b849d5bc34cad41feb676b6. Verify the file hash, then execute that file. Do not copy the file into this message."
exec /Users/a2026/.local/bin/agent --model auto --print --force --trust --workspace /Users/a2026/work/factory-prod-1 --output-format text "$PROMPT" >> "$OUT/agent.stdout" 2>> "$OUT/agent.stderr"
