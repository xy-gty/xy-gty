# Private engineering preparation — DocBrief AI

Status: ready

dispatch_id: 37bf6106-5b86-4137-a6a7-fe06781a6818  
run_id: kf-20261013T095745Z-aa3ad9a0  
attempt: 1  
technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0  
foundation: AppRuntimeCore 1.0.0 via `factory.ultra_lite_foundation install`  
preparation_cache: built shared AppRuntimeCore domain-test baseline (key 56cc6f2b80f2a7f17e52284ed171712d9d8aa28f02e1843d038537d75283a7ad); scratch under attempt host-compile / domain-compile-scratch only  

## Owned scope

Shared domain entities, interfaces, storage facades, navigation routes, consent/outbound boundary, BriefingTTS seam, and Vendor/AppRuntimeCore install. No UI design, Simulator, product repo, PM/stage MAP, or formal complete.

## Frozen match

- identity: DocBrief AI / com.lingguang.docbrief / en-US  
- entities: Brief, DocumentPhoto, RecognitionDraft, ExtractedField, ActionItem, SummaryCardDraft, AIConsentRecord, BriefingSession  
- interfaces: RecognitionReviewBar, ActionReview, SummaryCardPreview, AIConsentGate, PhotoImportSession, AtomicCodableStore, KeychainCredentialStore, TypedNavigationStore, RuntimeForm (library only), BriefingTTS  
- navigation: HomeTab → NewBrief → ImportCapture → RecognitionReview → BriefDetail → ChatExtract / ActionReview / SummaryCard / TTSBriefing; Settings → LegalPages; ConsentSheet  
- review_controls: Save / Not this / Edit fields; SummaryCard Use / Discard  
- consent: DeepSeek + docbrief.consent.v1; outbound fields allowlist matched  

## Source inventory

| ref | sha256 |
|---|---|
| DocBriefDomain/BriefingTTS.swift | bb1a0414fe94a7d10dfd8554e65a4d11de70362ae191fa81a0b78114c339bfd8 |
| DocBriefDomain/ConsentFacade.swift | d1d01273b3ab69db153f936c75bdc1431646f9084b2ace2d07f592c8691c3817 |
| DocBriefDomain/Entities.swift | 4a38e81e1601eb99a7de404a3982d12489b64784187c23bbf4333cef604d9598 |
| DocBriefDomain/Identity.swift | 4ff9c486a3f5cf4a93d0fc9512e10dd3cbce2e046a48814f332d0abc6a9abf16 |
| DocBriefDomain/Navigation.swift | 955d8e5c67b591fa0e6748e5ff9613bd35d775f4785857fb49e67257fba24b00 |
| DocBriefDomain/OutboundAIBoundary.swift | 26d9a5ea97ac89cee66da0aa6db2266489289a1668a6e80bad772e80410a225d |
| DocBriefDomain/PhotoImportFacade.swift | 5ead46f1db9bc2671fb9e6dba1312de0b7b626918d8a5e1085d2d20b33408c45 |
| DocBriefDomain/ReviewControls.swift | 00c1a67cef90ac7f288163422821435d49b44dc68fa755ce5e129b974fbf8090 |
| DocBriefDomain/StorageFacades.swift | 6ce57d73b9f3974235995c0ac86e9c1a0e8ed772d262c530d449f23ae87f26e7 |
| Package.swift | 0dbb22d2ec0b33113eb9b0f9caabe80658027ec2794c799607f4d6f99c5607c8 |
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
