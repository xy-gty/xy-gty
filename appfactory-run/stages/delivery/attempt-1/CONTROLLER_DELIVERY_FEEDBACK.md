# Controller delivery feedback — DocBrief AI

Operator-authorized constraints for delivery attempt-1:

1. **Feishu deferred** — do NOT call Feishu Bitable writeback / delivery card / notify-delivery. Record gap `feishu_deferred_operator` and continue. Fail-soft; does not block Status: ready.
2. **Product push target** — push product to `git@github.com:xy-gty/xy-gty.git` (prefer this remote). Use `ensure-product-github` / `publish-run-context` only if they do not conflict; if factory defaults to GaleInfra, still ensure `xy-gty/xy-gty.git` receives the product HEAD (add remote `xy-gty` and push `main` if needed).
3. **Accept gate** — upstream ai_app_accept attempt-2 MAP Verdict: ready; package_acceptance=accepted; candidate `09c4c0c3ca4b-7ce60dbd04e8`; product commit `09c4c0c3ca4b546b94253a7cd3d89f119e0b272b`.
4. **Four-perm** — already validated in accept2 (NSCamera/NSPhotoLibrary/NSMicrophone/NSSpeechRecognition + Take photo / Add photos / Voice supplement). Cite accept evidence; do not re-test product.
5. **Soft UL-07** — known_issues only (filled-state / wrong-screen); not blockers.
6. **Non-blocking gaps** — ai_key_unavailable, legal_url_unknown, cloudkit_unconfigured, feishu_deferred_operator, operator_pricing_deferred_free_app_only.
7. Also write operator-facing summary to `work/docbrief-delivery-report.md` (mirror of MAP highlights). If an existing App 记录 / 表格 helper can create a row without Feishu delivery card, use it and put record_id in MAP; if table missing, report literally and do NOT create a new table.

Finish with `Status: ready` when accept gate holds and product is pushed (Feishu absent OK).
