//
//  Foundationmodelsservice.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//

import Foundation          
import Combine
import FoundationModels

// MARK: - Conversation Message

struct ConversationMessage: Identifiable, Equatable {
    let id = UUID()
    let role: MessageRole
    let chineseText: String
    let pinyinText: String
    let englishText: String
    let timestamp: Date
    let isClosing: Bool

    enum MessageRole {
        case npc, user
    }

    init(role: MessageRole, chinese: String, pinyin: String, english: String, isClosing: Bool = false) {
        self.role = role
        self.chineseText = chinese
        self.pinyinText = pinyin
        self.englishText = english
        self.timestamp = Date()
        self.isClosing = isClosing
    }
}

// MARK: - Foundation Models Generable Output

@available(iOS 26.0, *)
@Generable
struct NPCReply {
    // FIX: Hapus properti chineseText duplikat. Hanya boleh ada satu.
    @Guide(description: """
        NPC reply in Simplified Chinese characters only. No pinyin, no English.
        Maximum 2-3 short sentences. Beginner-friendly vocabulary.
        """)
    var chineseText: String

    @Guide(description: """
        Pinyin romanization of chineseText with tone marks.
        Example: "Ni hao! Zuijin gongzuo zenme yang?"
        """)
    var pinyinText: String

    @Guide(description: """
        Natural English translation of chineseText.
        Example: "Hello! How has work been lately?"
        """)
    var englishText: String

    @Guide(description: """
        Set to true ONLY when the conversation goal is fully achieved and \
        you have said a proper goodbye. In most turns this must be false.
        """)
    var isConversationComplete: Bool
}

// MARK: - Foundation Models Service

@MainActor
class FoundationModelsService: ObservableObject {

    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var isConversationComplete = false

    private var scenario: NPCScenario

    private var _sessionStorage: AnyObject?

    @available(iOS 26.0, *)
    private var _session: LanguageModelSession? {
        get { _sessionStorage as? LanguageModelSession }
        set { _sessionStorage = newValue }
    }

    // MARK: - Init

    init(scenario: NPCScenario) {
        self.scenario = scenario
    }

    // MARK: - Opening Message

    var openingMessage: ConversationMessage {
        scenario.initialMessage
    }

    // MARK: - Generate NPC Response

    func generateResponse(
        to userChinese: String,
        languageAnalysis: LanguageAnalysisResult? = nil
    ) async -> ConversationMessage {
        guard !isConversationComplete else {
            return ConversationMessage(
                role: .npc,
                chinese: "再见！",
                pinyin: "Zàijiàn!",
                english: "Goodbye!"
            )
        }

        isGenerating = true
        defer { isGenerating = false }

        print("🟡 [FM] generateResponse called with: \"\(userChinese)\"")

        if #available(iOS 26.0, *) {
            print("🟡 [FM] iOS 26 available — attempting Foundation Models")
            do {
                let reply = try await callFoundationModels(
                    userText: userChinese,
                    languageAnalysis: languageAnalysis
                )

                print("✅ [FM] SUCCESS — response: \"\(reply.chineseText)\"")
                print("✅ [FM] isConversationComplete: \(reply.isConversationComplete)")

                if reply.isConversationComplete {
                    isConversationComplete = true
                }

                return ConversationMessage(
                    role: .npc,
                    chinese: reply.chineseText,
                    pinyin: reply.pinyinText,
                    english: reply.englishText,
                    isClosing: reply.isConversationComplete
                )
            } catch {
                print("❌ [FM] ERROR: \(error)")
                print("❌ [FM] localizedDescription: \(error.localizedDescription)")
                errorMessage = "Foundation Models: \(error.localizedDescription)"
            }
        } else {
            print("❌ [FM] iOS 26 NOT available — device/simulator does not support Foundation Models")
        }

        // Fallback jika Foundation Models tidak tersedia
        print("⚠️ [FM] Using FALLBACK response")
        return ConversationMessage(
            role: .npc,
            chinese: "好的，请继续。",
            pinyin: "Hǎo de, qǐng jìxù.",
            english: "[FALLBACK] Foundation Models tidak aktif",
            isClosing: false
        )
    }

    // MARK: - Foundation Models Call

    @available(iOS 26.0, *)
    private func callFoundationModels(
        userText: String,
        languageAnalysis: LanguageAnalysisResult? = nil
    ) async throws -> NPCReply {
        let model = SystemLanguageModel.default

        print("🔍 [FM] Model availability: \(model.availability)")

        switch model.availability {
        case .available:
            print("✅ [FM] Model is available")
        case .unavailable(let reason):
            print("❌ [FM] Model NOT available — reason: \(reason)")
            switch reason {
            case .modelNotReady:
                throw FoundationModelsError.modelNotReady
            case .appleIntelligenceNotEnabled:
                throw FoundationModelsError.appleIntelligenceNotEnabled
            case .deviceNotEligible:
                throw FoundationModelsError.deviceNotEligible
            default:
                throw FoundationModelsError.unavailable
            }
        @unknown default:
            throw FoundationModelsError.unavailable
        }

        // Create new session with STAGE CONTEXT — reset each stage for fresh context
        let currentStage = scenario.currentStage
        let stageNumber = scenario.currentStageIndex
        let fullPrompt = scenario.baseSystemPrompt
            + "\n\n--- CURRENT STAGE INFO ---"
            + "\nStage: \(stageNumber)"
            + "\nStage Instructions:\n"
            + currentStage.stagePrompt
            + "\n--- END STAGE INFO ---\n"

        // Always create new session per stage to ensure context freshness
        _session = LanguageModelSession(instructions: fullPrompt)
        print("🔍 [FM] Created new session for STAGE \(stageNumber)")

        guard let session = _session else {
            print("❌ [FM] Session is nil after creation — throwing sessionFailed")
            throw FoundationModelsError.sessionFailed
        }

        let enhancedText = buildEnhancedInput(userText: userText, analysis: languageAnalysis, stageNumber: stageNumber)
        print("🔍 [FM] Sending to model: \"\(enhancedText)\"")

        let response = try await session.respond(
            to: enhancedText,
            generating: NPCReply.self
        )

        print("🔍 [FM] Raw response — chinese: \"\(response.content.chineseText)\" | complete: \(response.content.isConversationComplete)")

        let chinese = response.content.chineseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !chinese.isEmpty else {
            print("❌ [FM] chineseText is empty — throwing emptyResponse")
            throw FoundationModelsError.emptyResponse
        }

        return NPCReply(
            chineseText: chinese,
            pinyinText: response.content.pinyinText.trimmingCharacters(in: .whitespacesAndNewlines),
            englishText: response.content.englishText.trimmingCharacters(in: .whitespacesAndNewlines),
            isConversationComplete: response.content.isConversationComplete
        )
    }

    // MARK: - Build Enhanced Input

    private func buildEnhancedInput(
        userText: String,
        analysis: LanguageAnalysisResult?,
        stageNumber: Int = 0
    ) -> String {
        var enhancedText = userText

        if let analysis = analysis {
            let tokenStr = analysis.tokens.joined(separator: ", ")
            let sentimentStr = String(describing: analysis.sentiment)
            let timelineKeywords = NaturalLanguageService().extractTimelineKeywords(from: userText)

            let contextInfo = "[STAGE: \(stageNumber) | SENTIMENT: \(sentimentStr) | TOKENS: \(tokenStr)"
                + (timelineKeywords.isEmpty ? "" : " | TIMELINE_KEYWORDS: \(timelineKeywords.joined(separator: ", "))")
                + "] "

            enhancedText = contextInfo + userText
        }

        return enhancedText
    }

    // MARK: - Reset

    func reset() {
        isConversationComplete = false
        errorMessage = nil
        if #available(iOS 26.0, *) { _session = nil }
    }

    func switchScenario(to newScenario: NPCScenario) {
        scenario = newScenario
        reset()
    }
}

// MARK: - Custom Errors

// FIX: Conform ke LocalizedError (bukan hanya Error) dan import Foundation
// agar errorDescription dan localizedDescription berfungsi dengan benar.
enum FoundationModelsError: LocalizedError {
    case unavailable
    case sessionFailed
    case emptyResponse
    case unknown
    case modelNotReady
    case appleIntelligenceNotEnabled
    case deviceNotEligible

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Foundation Models are unavailable on this device."
        case .sessionFailed:
            return "Could not create language model session."
        case .emptyResponse:
            return "Model returned an empty response."
        case .unknown:
            return "Unknown Foundation Models error."
        case .modelNotReady:
            return "The model is not ready yet. Please try again later."
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled on this device."
        case .deviceNotEligible:
            return "This device is not eligible for Foundation Models."
        }
    }
}
