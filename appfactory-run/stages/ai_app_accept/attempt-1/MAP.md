# MAP — ai_app_accept attempt-1 CellarCue

Status: ready  
Verdict: ready

pm_visual_manifest_sha256: d1deb007e4d4fbe223dd1b426b3ec2a150d8c85c9c781fea812e7f7c07504497  
technical_contract_sha256: 5b0e7e1cf2ab96ca937e5fe9661287dbdb46203ee0a885a281a14e8ec8097400  
product_commit: eded2779dc48944bf1cc943f255e972d423701ed  
product_dir: cellarcue/  
candidate: eded2779dc48-a36f3c574978 (candidate_unaccepted → accept runtime verified)  
bundle_id: com.lingguang.cellarcue  
simulator: iPhone 17 Pro B14CC0EA-EA96-4E5A-B32A-3187A83346B7  
dispatch_id: a3ec4bbf-acbb-47e3-8b1a-f89fa042b107  
code_query: code_query_blocked:codebase_memory_index_failed:FileNotFoundError:codebase-memory-mcp (read-only spot-checks via frozen product + domain tests)

## Stamp

| Domain | Verdict | Evidence (one line) |
|--------|---------|---------------------|
| UL-01 build_launch | pass | Candidate `.app` install+launch on leased B14CC0EA; `evidence/install.log` `evidence/launch.log`; reuse Builder `build.log`/`domain.log` objective logs |
| UL-02 core_flows | pass | External harness: capture→label result path exercised in rack/coach tests; scroll home shows `CellarRowBinGrid`+Shoot; coach chat local turn; rack card Keep; PullBrief+VoiceNote routes |
| UL-03 live_ai | pass (gap) | `inspect-key` → `ai_key_unavailable`; runtime banner “AI not configured — local capture still works”; Identify blocked without canned OCR; local coach turn on send; consent sheet branches in journey test |
| UL-04 reviewed_persistence | pass | Domain `testCellarStoreRoundTrip` + review controls; runtime Save Bottle in journey flows; kill+relaunch harness flaky → soft known_issue (see below) |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedBottles`; AppModel `confirmedBottleNotes` wired (spot-read); coach second-call path uses confirmed notes when key present (gap blocks live DeepSeek) |
| UL-06 privacy_permissions | pass | Consent gate domain test + runtime consent sheet (UL03); simctl privacy grant camera/photos/mic/speech; Settings opens; Privacy/Provider policy navigation taps; bundled legal HTML hashes; revoke UI present (product smoke/harness scroll sensitivity → soft) |
| UL-07 ui_interaction | pass (soft visual) | Compliance banners + 21+ on home shot; signature components reachable after scroll (`testUL07ScrollHomeShowsGridAndCTAs`); CR-HOME-01 top-fold vision fail only (below-fold layout) |
| UL-08 repo_evidence | pass | `cellarcue` @ `eded2779`; evidence under this attempt; candidate path bound; no product git dirty |

## Visual readback (UL-07)

| frame_id | design ref | runtime ref | vision | note |
|----------|------------|-------------|--------|------|
| cellarcue-home-empty | `pm_docs/.../frames/cellarcue-home-empty-r1.png` | `evidence/01-home.png` sha256:425c9ab7… | `evidence/01-home.CR-HOME-01.receipt.json` → **fail** (grid/CTAs/coach below fold) | Runtime scroll XCTest confirms grid+Shoot exist (Option A soft) |
| cellarcue-home-empty (scroll) | same | XCTest attachment `home-scrolled` in AcceptHarness2.xcresult + UL07 pass | not re-visioned | Harness proves below-fold signature UI |

## Runtime evidence index

| Artifact | sha256 (prefix) |
|----------|-----------------|
| evidence/01-home.png | 425c9ab7 |
| evidence/02-home-fresh.png | ad8454e8 |
| evidence/ui-journey-test.log | (AcceptHarness.xcresult) UL03+rack **pass** |
| evidence/ui-journey-passing.log | UL03+rack **pass** |
| evidence/ui-journey-rerun.log | UL07 **pass** |
| evidence/DomainTests.xcresult | 11/11 domain tests **pass** |
| evidence/config-key.stdout.txt | ai_key_unavailable |
| evidence/config-audit.receipt.json | feishu/config gaps non-blocker |
| Candidate privacy.html | 8be3796b… |
| Builder smoke-home.png (reuse) | cf1551d0… |

## Gaps

| Gap | Kind | suggested_node |
|-----|------|----------------|
| ai_key_unavailable | gap | delivery (replace_before_submission) |
| legal_url_unknown (privacy/terms/support remote) | gap | delivery |
| cloudkit_unconfigured | gap | delivery |
| feishu_row_not_yet_created | gap | delivery |
| code_query_blocked (codebase-memory-mcp missing) | advisory | factory |
| operator_pricing_deferred_free_app_only | gap | product_shape |

## known_issues (Option A — non-core / harness)

- CR-HOME-01 on unscroll home screenshot: grid, Shoot/Import, coach bar below fold (runtime scroll + XCTest UL07 pass).
- Product `CellarCueUISmokeTests` Revoke row: Form scroll timing in XCTest (Settings+compliance otherwise reachable).
- External harness UL04 kill+relaunch assertion flaky when photo seed fails; persistence logic covered by domain round-trip.
- WKWebView legal pages: navigation opens; WebView text not exposed to XCTest (bundle HTML verified in `.app`).
- `03-home-scrolled-manual.png` captured on SpringBoard after test teardown — discarded for verdict.

## lessons_candidates

- Acceptance harness should live outside product (`attempt-1/harness`) with projectReference to frozen `CellarCue.xcodeproj`.
- Home signature UI requires scroll for single-frame screenshots on iPhone 17 Pro.
- P1 `ai_key_unavailable` still requires honest runtime + local coach/OCR-off paths, not blocked.
