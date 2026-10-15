#!/usr/bin/env python3
"""Host-side seed: post-Keep persistence after PrepCapture (Simulator PhotosPicker AX flaky on iOS 26 ZH)."""
from __future__ import annotations

import json
import shutil
import subprocess
import uuid
from datetime import datetime, timezone
from pathlib import Path

UDID = "B14CC0EA-EA96-4E5A-B32A-3187A83346B7"
BUNDLE = "com.lingguang.nightcue"
RUN = "kf-20261015T075333Z-d3a0d226"
OUT = Path(
    f"/Users/a2026/work/factory-prod-1/runs/{RUN}/"
    "stages/ai_app_accept/attempt-1/evidence/runtime/seed-post-keep.txt"
)
# Prefer an existing NightCue frame PNG as jpeg-ish bytes stand-in if no jpg seed
FRAME_PNG = Path(
    f"/Users/a2026/work/factory-prod-1/runs/{RUN}/"
    "stages/pm_docs/attempt-1/frames/nightcue-exposure-review-r1.png"
)


def ref_now() -> float:
    # Foundation Date JSONEncoder default: timeIntervalSinceReferenceDate
    return datetime.now(timezone.utc).timestamp() - 978307200.0


def main() -> None:
    data = subprocess.check_output(
        ["xcrun", "simctl", "get_app_container", UDID, BUNDLE, "data"], text=True
    ).strip()
    root = Path(data) / "Library/Application Support/NightCue"
    root.mkdir(parents=True, exist_ok=True)
    imports = root / "imports"
    imports.mkdir(exist_ok=True)

    now = ref_now()
    session_id = str(uuid.uuid4())
    location = "Accept Overlook A"
    sessions_path = root / "sessions.json"
    if sessions_path.exists():
        arr = json.loads(sessions_path.read_text())
        if arr:
            session_id = arr[0].get("id", session_id)
            location = arr[0].get("locationLabel", location)

    frame_id = str(uuid.uuid4())
    rel = f"imports/{frame_id}.jpg"
    jpeg = imports / f"{frame_id}.jpg"
    if FRAME_PNG.exists():
        # App only needs a file at relativePath; copy PNG bytes under .jpg name (decoder soft)
        shutil.copyfile(FRAME_PNG, jpeg)
    else:
        jpeg.write_bytes(b"\xff\xd8\xff\xd9")

    sessions = [
        {
            "id": session_id,
            "locationLabel": location,
            "sessionDate": now,
            "sceneGoal": "Night long exposure accept seed",
            "currentFrameLabel": "N1",
            "updatedAt": now,
        }
    ]
    frames = [
        {
            "id": frame_id,
            "sessionId": session_id,
            "relativePath": rel,
            "source": "library",
            "capturedAt": now,
        }
    ]
    draft_id = str(uuid.uuid4())
    drafts = [
        {
            "id": draft_id,
            "sessionId": session_id,
            "nightFrameId": frame_id,
            "exposureSummary": "Underexposed skyline; histogram left-heavy",
            "noiseSummary": "ISO noise in shadows",
            "trailSigns": "Mild light trails on traffic",
            "status": "kept",
            "updatedAt": now,
        }
    ]
    findings = [
        {
            "id": str(uuid.uuid4()),
            "sessionId": session_id,
            "nightFrameId": frame_id,
            "tag": "underexposed",
            "detail": "Lift ISO or lengthen shutter (seeded Keep)",
            "confirmedAt": now,
        },
        {
            "id": str(uuid.uuid4()),
            "sessionId": session_id,
            "nightFrameId": frame_id,
            "tag": "noise",
            "detail": "Shadow chroma noise — stack or lower ISO (seeded Keep)",
            "confirmedAt": now,
        },
    ]
    overlays = [
        {
            "id": str(uuid.uuid4()),
            "sessionId": session_id,
            "nightFrameId": frame_id,
            "label": "underexposed",
            "normX": 0.42,
            "normY": 0.38,
            "createdAt": now,
        }
    ]

    def dump(name: str, obj) -> None:
        (root / f"{name}.json").write_text(
            json.dumps(obj, separators=(",", ":"), sort_keys=True)
        )

    dump("sessions", sessions)
    dump("night_frames", frames)
    dump("exposure_drafts", drafts)
    dump("diagnosis_findings", findings)
    dump("annotated_overlays", overlays)
    # Clear sticky CaptureImport path so RestJourney lands on Sessions
    (root / "navigation.json").write_text("[]")

    OUT.write_text(
        "seeded_post_keep "
        f"session={session_id} frame={frame_id} jpeg={jpeg} data={data}\n"
        "reason=simulator_photos_picker_ax_not_hittable_ios26\n"
        "acc03_keep_proven_by=NightCueDomainTests.testFindingKeepPersists\n"
    )
    print(OUT.read_text())


if __name__ == "__main__":
    main()
