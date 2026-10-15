#!/usr/bin/env python3
"""Seed NightCue Application Support on leased simulator (acceptance evidence only)."""
from __future__ import annotations

import datetime as dt
import json
import shutil
import subprocess
import sys
from pathlib import Path

UDID = "B14CC0EA-EA96-4E5A-B32A-3187A83346B7"
BUNDLE = "com.lingguang.nightcue"
RUN = Path(__file__).resolve().parents[4]
IMG_SRC = RUN / "stages/pm_docs/attempt-1/frames/nightcue-exposure-review-r1.png"


def swift_date(d: dt.datetime) -> float:
    ref = dt.datetime(2001, 1, 1, tzinfo=dt.timezone.utc)
    if d.tzinfo is None:
        d = d.replace(tzinfo=dt.timezone.utc)
    return (d - ref).total_seconds()


def main() -> int:
    subprocess.run(["xcrun", "simctl", "launch", UDID, BUNDLE], check=False, capture_output=True)
    out = subprocess.run(
        ["xcrun", "simctl", "get_app_container", UDID, BUNDLE, "data"],
        check=True,
        capture_output=True,
        text=True,
    )
    data_root = Path(out.stdout.strip())
    root = data_root / "Library/Application Support/NightCue"
    imports = root / "imports"
    imports.mkdir(parents=True, exist_ok=True)
    frame_name = "accept-seed.jpg"
    shutil.copy(IMG_SRC, imports / frame_name)

    now = dt.datetime.now(dt.timezone.utc)
    t = swift_date(now)
    sid, fid = "accept-session-1", "accept-frame-1"

    sessions = [
        {
            "currentFrameLabel": "N1",
            "id": sid,
            "locationLabel": "Bridge overlook",
            "sceneGoal": "Night long exposure",
            "sessionDate": t,
            "updatedAt": t,
        }
    ]
    frames = [
        {
            "capturedAt": t,
            "id": fid,
            "relativePath": f"imports/{frame_name}",
            "sessionId": sid,
            "source": "library",
        }
    ]
    findings = [
        {
            "confirmedAt": t,
            "detail": "Lift ISO or lengthen shutter for skyline",
            "id": "accept-finding-1",
            "nightFrameId": fid,
            "sessionId": sid,
            "tag": "underexposed",
        }
    ]
    cues = [
        {
            "createdAt": t,
            "cueKind": "iso",
            "id": "cue-1",
            "sessionId": sid,
            "sortIndex": 0,
            "text": "Set ISO to 800 or lower if shutter can hold.",
        }
    ]
    navigation = ["NightCoach"]

    for name, payload in [
        ("sessions", sessions),
        ("night_frames", frames),
        ("diagnosis_findings", findings),
        ("field_cues", cues),
        ("exposure_drafts", []),
        ("annotated_overlays", []),
        ("coach_turns", []),
        ("coach_messages", []),
        ("dictated_exposures", []),
    ]:
        (root / f"{name}.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    (root / "navigation.json").write_text(json.dumps(navigation, indent=2), encoding="utf-8")
    print(json.dumps({"ok": True, "root": str(root), "session_id": sid}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
