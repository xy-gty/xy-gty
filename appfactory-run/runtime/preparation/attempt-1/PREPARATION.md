# Private engineering preparation — BendCoach AI

Status: ready

dispatch_id: 314716df-0575-4244-b78d-38d05c5af901  
run_id: kf-20261013T132652Z-d15977ae  
attempt: 1  
technical_contract_sha256: b43b4db81ea320561037660a574d8d0b620ca87f7d34a52fcece3c1fc6678d19  
foundation: AppRuntimeCore 1.0.0 via `factory.ultra_lite_foundation install`  
preparation_cache: hit shared AppRuntimeCore domain-test baseline (key 56cc6f2b80f2a7f17e52284ed171712d9d8aa28f02e1843d038537d75283a7ad); scratch under attempt host-compile / domain-compile-scratch only  

## Owned scope

Shared domain entities, interfaces, storage facades, navigation routes, consent/outbound boundary, CoachingTTS / SpeechRecognitionBridge / UnitSystemControl seams, and Vendor/AppRuntimeCore install. No UI design, Simulator, product repo, PM/stage MAP, or formal complete.

## Frozen match

- identity: BendCoach AI / com.lingguang.bendcoach / en-US  
- entities: JobSession, BendQuery, FieldPhoto, BendRecognitionDraft, BendMarkup, DiagramOverlay, CoachingStep, UnitPreference, AIConsentRecord, SpeechCaptureSession  
- interfaces: BendReviewBar, DiagramPreview, AIConsentGate, PhotoImportSession, CameraCapture, SpeechRecognitionBridge, CoachingTTS, UnitSystemControl, AtomicCodableStore, KeychainCredentialStore, TypedNavigationStore, RuntimeForm (library only)  
- navigation: HomeTab, BendMathChat, CaptureImport, BendReview, JobDetail, DiagramOverlay, TTSCoaching, SpeechCapture, Settings, Units, LegalPages, ConsentSheet  
- review_controls: Save / Not this / Edit marks; DiagramPreview Use / Discard  
- consent: DeepSeek + bendcoach.consent.v1; outbound fields allowlist matched  

## Source inventory

| ref | sha256 |
|---|---|
| BendCoachDomain/CoachingTTS.swift | aa77dc0b01343b84dd4e362a0b2a96a1ed05f2c8769f49cfec57372806671685 |
| BendCoachDomain/ConsentFacade.swift | adc1564b16d6e49b6d7e731ab663b3371a78787fcd8189138067f160b57e3a74 |
| BendCoachDomain/Entities.swift | c04fefaaf8cd63f95633c97e6d7b4f8cf68a5b05a52a2d15c72ab7171c88dd43 |
| BendCoachDomain/Identity.swift | 7a9c49d166be795652ab9882089c0b2ef9168a8590edb68566d4e2f998741bf4 |
| BendCoachDomain/Navigation.swift | 795b1186ec0aa9f547fe8751b9c0106b08afe83fb1cd3c27447a1647de7ed18e |
| BendCoachDomain/OutboundAIBoundary.swift | a29897a0d2052033789b8bc995262cb3a85571ba1344a50b460c4eb4338a875d |
| BendCoachDomain/PhotoImportFacade.swift | be2d19f9813f3e7f494040d46dff23244490c8bdac63cf7796fba2d718dbac26 |
| BendCoachDomain/ReviewControls.swift | 560619aa369bc2128c13e1767b3b7352392ecdf906f9ebe95c3b5779a935beec |
| BendCoachDomain/SpeechRecognitionBridge.swift | 40d6d3c7719238e45cfa9eccbe5e2783b69a94a7ce31fcb62b55b5e4d71df77f |
| BendCoachDomain/StorageFacades.swift | db8c5481161cb619c948cfa5341f0a1a45a6c78cee65e0888c118433276bd3f4 |
| BendCoachDomain/UnitSystemControl.swift | 80046fe48d42d42b0624a4fd33d7ef7e6aa9099048f06a2f20be509ab56d063a |
| Package.swift | 74e537b75134b39e50fe0420427eac7b8104713ebdb3d90ea0c3001c94e692f1 |
| Vendor/AppRuntimeCore/Package.swift | ee9231b48e8eec965fd8a78c3aaa7e1023adcbbd5417285fffaaaf330ebeee0e |
| Vendor/AppRuntimeCore/Sources/AppRuntimeCore/AIConsentGate.swift | 6f86ec21e6943637efcc0a7b7efa30db0480aff8a8797c2162e59f9ea6e0df0a |
| Vendor/AppRuntimeCore/Sources/AppRuntimeCore/AtomicCodableStore.swift | d16b83207201ca6ed3ca994da3d691ec0be6be3a529b61e4614fb3305a5bbe37 |
| Vendor/AppRuntimeCore/Sources/AppRuntimeCore/KeychainCredentialStore.swift | c6dfe3191f9c2f6f41170c3b2ba98e37719bf769d95f3fb7426df06eb9f30019 |
| Vendor/AppRuntimeCore/Sources/AppRuntimeCore/PhotoImportSession.swift | 34f651ac82c03c353eae543ef92db9ba116327ef05e8dd52686f8ab9afe575d7 |
| Vendor/AppRuntimeCore/Sources/AppRuntimeCore/RuntimeForm.swift | 75f8180339801554908f95580d1fbf562616715b35b41ba633a9f34a8d398ef2 |
| Vendor/AppRuntimeCore/Sources/AppRuntimeCore/TypedNavigationStore.swift | eb4c6607212e57cab3df9fad426bd2d6db381fcca8ea5cacc38adc13c035e145 |
| Vendor/AppRuntimeCore/foundation.v1.json | 5ac3406501873b4c8c260ba7f5ecc8c7786ecf2d7630a6661bb9faa78525e44c |

## Notes

Preparation ready ≠ product runnable or accepted. Formal Builder must consume seal after PM validated design.
