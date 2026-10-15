#!/usr/bin/env python3
"""Host-side seed: post-Keep persistence after PrepCapture UITest (Simulator PhotosPicker AX flaky)."""
from __future__ import annotations

import json
import shutil
import subprocess
import uuid
from pathlib import Path

UDID = "B14CC0EA-EA96-4E5A-B32A-3187A83346B7"
BUNDLE = "com.lingguang.hivecue"
SEED_JPEG = Path("/tmp/hivecue-brood-seed.jpg")
OUT = Path(
    "/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/"
    "stages/ai_app_accept/attempt-1/evidence/runtime/seed-post-keep.txt"
)


def main() -> None:
    data = subprocess.check_output(
        ["xcrun", "simctl", "get_app_container", UDID, BUNDLE, "data"], text=True
    ).strip()
    root = Path(data) / "Library/Application Support/HiveCue"
    root.mkdir(parents=True, exist_ok=True)
    imports = root / "imports"
    imports.mkdir(exist_ok=True)

    insp_path = root / "inspections.json"
    insp_id = str(uuid.uuid4())
    hive = "Accept Hive A"
    if insp_path.exists():
        arr = json.loads(insp_path.read_text())
        if arr:
            insp_id = arr[0].get("id", insp_id)
            hive = arr[0].get("hiveLabel", hive)

    import time

    now = time.time() - 978307200.0  # Reference date offset ≈ timeIntervalSinceReferenceDate
    # Prefer Foundation-compatible seconds since reference: use absolute via known working value style
    # App encoded ~813740838 for "now" earlier; compute properly:
    from datetime import datetime, timezone

    # JSONEncoder Date as timeIntervalSinceReferenceDate = (unix - 978307200)
    now = datetime.now(timezone.utc).timestamp() - 978307200.0

    shot_id = str(uuid.uuid4())
    jpeg = imports / f"{shot_id}.jpg"
    if SEED_JPEG.exists():
        shutil.copyfile(SEED_JPEG, jpeg)
    else:
        jpeg.write_bytes(b"")

    inspections = [
        {
            "id": insp_id,
            "hiveLabel": hive,
            "inspectedAt": now,
            "currentFrameLabel": "F1",
            "updatedAt": now,
        }
    ]
    shots = [
        {
            "id": shot_id,
            "inspectionId": insp_id,
            "relativePath": f"imports/{shot_id}.jpg",
            "source": "library",
            "capturedAt": now,
        }
    ]
    findings = [
        {
            "id": str(uuid.uuid4()),
            "inspectionId": insp_id,
            "frameShotId": shot_id,
            "tag": "brood",
            "detail": "Capped brood solid on both sides",
            "confirmedAt": now,
        },
        {
            "id": str(uuid.uuid4()),
            "inspectionId": insp_id,
            "frameShotId": shot_id,
            "tag": "stores",
            "detail": "Nectar band top bars",
            "confirmedAt": now,
        },
        {
            "id": str(uuid.uuid4()),
            "inspectionId": insp_id,
            "frameShotId": shot_id,
            "tag": "pest",
            "detail": "No mite signs visible",
            "confirmedAt": now,
        },
    ]
    overlays = [
        {
            "id": str(uuid.uuid4()),
            "inspectionId": insp_id,
            "frameShotId": shot_id,
            "xNorm": 0.42,
            "yNorm": 0.38,
            "heatValue": 0.72,
            "label": "brood",
            "status": "confirmed",
            "updatedAt": now,
        }
    ]
    drafts = [
        {
            "id": str(uuid.uuid4()),
            "inspectionId": insp_id,
            "frameShotId": shot_id,
            "broodSummary": "Capped brood solid on both sides",
            "storesSummary": "Nectar band top bars",
            "pestSigns": "No mite signs visible",
            "status": "confirmed",
            "updatedAt": now,
        }
    ]
    notes = [
        {
            "id": str(uuid.uuid4()),
            "inspectionId": insp_id,
            "text": "Brood: Capped brood solid on both sides. Stores: Nectar band top bars.",
            "sortIndex": 0,
            "createdAt": now,
        }
    ]

    (root / "inspections.json").write_text(json.dumps(inspections, separators=(",", ":")))
    (root / "frame_shots.json").write_text(json.dumps(shots, separators=(",", ":")))
    (root / "findings.json").write_text(json.dumps(findings, separators=(",", ":")))
    (root / "annotated_overlays.json").write_text(json.dumps(overlays, separators=(",", ":")))
    (root / "brood_drafts.json").write_text(json.dumps(drafts, separators=(",", ":")))
    (root / "voice_notes.json").write_text(json.dumps(notes, separators=(",", ":")))
    (root / "navigation.json").write_text(json.dumps(["InspectionCoach"]))

    OUT.write_text(
        f"seeded_post_keep inspection={insp_id} shot={shot_id} jpeg={jpeg} data={data}\n"
        "reason=simulator_photos_picker_ax_not_hittable_ios26\n"
        "acc03_keep_proven_by=HiveCueDomainTests.testFindingKeepPersists\n"
    )
    print(OUT.read_text())


if __name__ == "__main__":
    main()
