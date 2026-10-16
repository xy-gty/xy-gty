import Foundation
import AppRuntimeCore

/// Review affordances from technical contract.
public enum MixReviewControls {
    public static let confirm = ["Save Mix", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit pour steps"]
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "stirboard.consent.v1"
    public static let fields = [
        "bottle_label_garnish_still",
        "user_question",
        "confirmed_spirits_substitutes",
        "active_recipe_id",
        "optional_voice_transcript",
    ]

    @MainActor
    public static func makeGate(
        load: @escaping () throws -> AIConsentGate.State?,
        persist: @escaping (AIConsentGate.State) throws -> Void
    ) -> AIConsentGate {
        AIConsentGate(
            provider: provider,
            disclosureVersion: disclosureVersion,
            load: load,
            persist: persist
        )
    }
}

/// Interface name literals for deferred Builder wiring (no UI).
public enum StirboardInterfaceNames {
    public static let mixStore = "MixStore"
    public static let photoCaptureService = "PhotoCaptureService"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let spiritIDClient = "SpiritIDClient"
    public static let coachChatClient = "CoachChatClient"
    public static let pourBoardBuilder = "PourBoardBuilder"
    public static let ttsPlayer = "TTSPlayer"
    public static let voiceNoteRecorder = "VoiceNoteRecorder"
    public static let speechQuestionIngress = "SpeechQuestionIngress"
    public static let consentGate = "ConsentGate"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let photoImportSession = "PhotoImportSession"
    public static let runtimeForm = "RuntimeForm"
    public static let aiConsentGate = "AIConsentGate"
}

/// Permission usage strings extending cocktail-coach core (no competitor names).
public enum PrivacyUsageCopy {
    public static let camera =
        "Capture bottle faces, labels, and garnish stills so Stirboard can identify base spirits for your mix session"
    public static let photoLibrary =
        "Import bar-shelf album stills to complete spirit identification in Stirboard"
    public static let microphone =
        "Record hands-free voice notes while both hands shake or stir"
    public static let speechRecognition =
        "Turn spoken substitute and recipe questions into coach chat text"
}

public enum StirboardIdentity {
    public static let appName = "Stirboard"
    public static let developmentBundleId = "com.lingguang.stirboard"
    public static let productDir = "stirboard"
    public static let uiLanguage = "en-US"
    public static let simulatorPrefUDID = "B14CC0EA"
}

public enum StirboardPalette {
    public static let primary = "#E11D48"
    public static let secondary = "#FFF1F2"
    public static let accent = "#CA8A04"
}

public enum StirboardUISpecies {
    public static let signature = "vertical_bottle_rail + large_next_pour_card + garnish_chip_row"
}

public enum StirboardGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}

public enum StirboardDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max", "iPhone 16 Pro Max", "iPhone 15 Pro Max"]
}

public enum StirboardAllergy {
    public static let bannedTwinShells = [
        "Fieldmark", "Mattebox", "Tablehost", "Onionreel", "Hemline", "Sunbrief",
    ]
    public static let bannedCompetitorNames = ["Cocktail Party", "Bevnap"]
    public static let requiredUI = [
        "vertical bottle-rail",
        "large next-pour card",
        "garnish chip row",
    ]
}

public enum StirboardPermissions {
    public static let required = ["Camera", "Photos", "Microphone", "Speech Recognition"]
}

/// Maps a recipe into pour-board presentation state (next-pour card + garnish chips).
public enum PourBoardBuilder {
    public static func currentStep(in recipe: RecipeCard, ordinal: Int) -> PourStep? {
        recipe.steps
            .sorted { $0.ordinal < $1.ordinal }
            .first { $0.ordinal == ordinal }
            ?? recipe.steps.sorted { $0.ordinal < $1.ordinal }.first
    }

    public static func advanceOrdinal(current: Int, recipe: RecipeCard) -> Int {
        let ordered = recipe.steps.map(\.ordinal).sorted()
        guard let idx = ordered.firstIndex(of: current), idx + 1 < ordered.count else {
            return ordered.last ?? current
        }
        return ordered[idx + 1]
    }

    public static func placeholderRecipe(sessionId: String, baseSpirit: String) -> RecipeCard {
        let recipeId = "local-\(sessionId.prefix(8))"
        let steps = [
            PourStep(
                sessionId: sessionId,
                recipeId: recipeId,
                ordinal: 1,
                action: "pour",
                amountMl: 45,
                durationSec: nil,
                instruction: "Pour 45 ml \(baseSpirit) into the shaker."
            ),
            PourStep(
                sessionId: sessionId,
                recipeId: recipeId,
                ordinal: 2,
                action: "pour",
                amountMl: 20,
                durationSec: nil,
                instruction: "Add 20 ml citrus or sweetener as your coach notes."
            ),
            PourStep(
                sessionId: sessionId,
                recipeId: recipeId,
                ordinal: 3,
                action: "shake",
                amountMl: nil,
                durationSec: 12,
                instruction: "Shake hard for 12 seconds — keep both hands on the tin."
            ),
            PourStep(
                sessionId: sessionId,
                recipeId: recipeId,
                ordinal: 4,
                action: "strain",
                amountMl: nil,
                durationSec: nil,
                instruction: "Strain into a chilled coupe."
            ),
            PourStep(
                sessionId: sessionId,
                recipeId: recipeId,
                ordinal: 5,
                action: "garnish",
                amountMl: nil,
                durationSec: nil,
                instruction: "Finish with the garnish chips below."
            ),
        ]
        let chips = [
            GarnishChip(sessionId: sessionId, recipeId: recipeId, name: "Citrus twist", placed: false, accentColor: StirboardPalette.accent),
            GarnishChip(sessionId: sessionId, recipeId: recipeId, name: "Herb sprig", placed: false, accentColor: StirboardPalette.primary),
            GarnishChip(sessionId: sessionId, recipeId: recipeId, name: "Bitters dash", placed: false, accentColor: StirboardPalette.accent),
        ]
        return RecipeCard(
            sessionId: sessionId,
            title: "Home bar mix · \(baseSpirit)",
            baseSpirit: baseSpirit,
            steps: steps,
            garnishChips: chips,
            substituteNotes: "Ask the coach for swaps if a bottle is missing."
        )
    }
}
