//
//  Foundationmodelsservice.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//

import Foundation
import Combine          // ← WAJIB untuk @Published + ObservableObject
import FoundationModels // ← iOS 26+ / Xcode 26 beta

// MARK: - Message Model

struct ConversationMessage: Identifiable, Equatable {
    let id = UUID()
    let role: MessageRole
    let chineseText: String     // 汉字
    let pinyinText: String      // Romanization
    let englishText: String     // Translation
    let timestamp: Date

    enum MessageRole {
        case npc, user
    }

    init(role: MessageRole, chinese: String, pinyin: String, english: String) {
        self.role = role
        self.chineseText = chinese
        self.pinyinText = pinyin
        self.englishText = english
        self.timestamp = Date()
    }
}

// MARK: - NPC Scenario

struct NPCScenario {
    let systemPrompt: String
    let initialMessage: ConversationMessage
    let expectedKeywords: [String]

    static let morningGreeting = NPCScenario(
        systemPrompt: """
        You are Lǐ Míng (李明), a friendly Chinese NPC in a language learning app.
        Your role: Have a short, natural Mandarin conversation with a beginner learner.

        Strict rules:
        - Respond ONLY in Simplified Chinese characters (汉字). No pinyin, no English.
        - Maximum 1–2 short sentences per reply.
        - Always end with a simple follow-up question to keep the conversation going.
        - Topic: Morning greetings, how are you, weather, daily plans.
        - Example reply: 很好，谢谢！今天天气怎么样？
        """,
        initialMessage: ConversationMessage(
            role: .npc,
            chinese: "你好！早上好。你今天怎么样？",
            pinyin: "Nǐ hǎo! Zǎoshang hǎo. Nǐ jīntiān zěnme yàng?",
            english: "Hello! Good morning. How are you today?"
        ),
        expectedKeywords: ["好", "hao", "fine", "great", "不错", "很好", "还好", "累", "tired"]
    )
}

// MARK: - Foundation Models Generable Output

/// Typed output schema so LanguageModelSession returns structured JSON
@available(iOS 26.0, *)
@Generable
struct NPCReply {
    @Guide(description: "NPC reply in Simplified Chinese characters only. No pinyin or English. 1-2 sentences maximum.")
    var chineseText: String
}

// MARK: - Foundation Models Service

@MainActor
class FoundationModelsService: ObservableObject {

    @Published var isGenerating = false
    @Published var errorMessage: String?

    private let scenario: NPCScenario

    // Keep history short — on-device model has limited context window
    private var conversationHistory: [(role: String, content: String)] = []

    // Reuse session across turns for context continuity
    // Stored as AnyObject to avoid @available on stored property
    private var _sessionStorage: AnyObject?

    @available(iOS 26.0, *)
    private var _session: LanguageModelSession? {
        get { _sessionStorage as? LanguageModelSession }
        set { _sessionStorage = newValue }
    }

    init(scenario: NPCScenario = .morningGreeting) {
        self.scenario = scenario
    }

    // MARK: - Generate NPC Response

    func generateResponse(to userChinese: String) async -> ConversationMessage {
        isGenerating = true
        defer { isGenerating = false }

        conversationHistory.append((role: "user", content: userChinese))

        // Try Foundation Models first (iOS 26 + Apple Intelligence)
        if #available(iOS 26.0, *) {
            do {
                let chinese = try await callFoundationModels(userText: userChinese)
                conversationHistory.append((role: "assistant", content: chinese))
                return enrichWithPinyinAndTranslation(chineseText: chinese)
            } catch {
                // Log but don't crash — fall through to rule-based
                errorMessage = "Foundation Models: \(error.localizedDescription)"
            }
        }

        // Rule-based fallback (always works, great for development)
        let fallback = getFallbackResponse(to: userChinese)
        conversationHistory.append((role: "assistant", content: fallback.chineseText))
        return fallback
    }

    // MARK: - Foundation Models (iOS 26+)

    @available(iOS 26.0, *)
    private func callFoundationModels(userText: String) async throws -> String {
        let model = SystemLanguageModel.default

        // Check Apple Intelligence availability
        // Using 'default' case to handle all unavailable states without
        // referencing UnavailabilityReason (not a member in this API version)
        switch model.availability {
        case .available:
            break // proceed
        default:
            throw FoundationModelsError.unavailable
        }

        // Create or reuse session with NPC system prompt
        if _session == nil {
            _session = LanguageModelSession(instructions: scenario.systemPrompt)
        }
        guard let session = _session else {
            throw FoundationModelsError.sessionFailed
        }

        // Use @Generable typed output for reliable structured response
        let response = try await session.respond(
            to: userText,
            generating: NPCReply.self
        )

        let chinese = response.content.chineseText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !chinese.isEmpty else {
            throw FoundationModelsError.emptyResponse
        }

        return chinese
    }

    // MARK: - Pinyin + Translation Enrichment

    private func enrichWithPinyinAndTranslation(chineseText: String) -> ConversationMessage {
        // Lookup table for known responses — expand as needed
        let map: [String: (String, String)] = [
            "你好！早上好。你今天怎么样？":
                ("Nǐ hǎo! Zǎoshang hǎo. Nǐ jīntiān zěnme yàng?",
                 "Hello! Good morning. How are you today?"),
            "很好，谢谢！你呢？":
                ("Hěn hǎo, xièxiè! Nǐ ne?",
                 "Very good, thank you! And you?"),
            "我也很好！今天天气真好。":
                ("Wǒ yě hěn hǎo! Jīntiān tiānqì zhēn hǎo.",
                 "I'm doing well too! The weather is really nice today."),
            "好的！今天有什么计划吗？":
                ("Hǎo de! Jīntiān yǒu shénme jìhuà ma?",
                 "Great! Any plans for today?"),
            "哦，为什么？发生什么了？":
                ("Ō, wèishénme? Fāshēng shénme le?",
                 "Oh, why? What happened?"),
            "是吗？今天天气真好。":
                ("Shì ma? Jīntiān tiānqì zhēn hǎo.",
                 "Is that so? The weather is really nice today."),
            "我也很好！今天有什么计划吗？":
                ("Wǒ yě hěn hǎo! Jīntiān yǒu shénme jìhuà ma?",
                 "I'm doing well too! Any plans for today?"),
            "好的！那我们明天再见。再见！":
                ("Hǎo de! Nà wǒmen míngtiān zàijiàn. Zàijiàn!",
                 "Great! See you tomorrow then. Goodbye!"),
            "好的。再见！":
                ("Hǎo de. Zàijiàn!", "Alright. Goodbye!"),
        ]

        if let (pinyin, english) = map[chineseText] {
            return ConversationMessage(role: .npc, chinese: chineseText,
                                       pinyin: pinyin, english: english)
        }

        // Unknown response from model — show raw Chinese, mark pinyin/english as pending
        return ConversationMessage(
            role: .npc,
            chinese: chineseText,
            pinyin: "—",
            english: "(AI response — translation pending)"
        )
    }

    // MARK: - Rule-Based Fallback

    private func getFallbackResponse(to userText: String) -> ConversationMessage {
        let lower = userText.lowercased()
        let isPositive = lower.contains("好") || lower.contains("hao") ||
                         lower.contains("fine") || lower.contains("great") || lower.contains("不错")
        let isNegative = lower.contains("不好") || lower.contains("累") || lower.contains("tired")

        let turnCount = conversationHistory.filter { $0.role == "user" }.count

        switch turnCount {
        case 1:
            if isPositive {
                return enrichWithPinyinAndTranslation(chineseText: "很好，谢谢！你呢？")
            } else if isNegative {
                return enrichWithPinyinAndTranslation(chineseText: "哦，为什么？发生什么了？")
            } else {
                return enrichWithPinyinAndTranslation(chineseText: "是吗？今天天气真好。")
            }
        case 2:
            return enrichWithPinyinAndTranslation(chineseText: "我也很好！今天有什么计划吗？")
        case 3:
            return enrichWithPinyinAndTranslation(chineseText: "好的！那我们明天再见。再见！")
        default:
            return enrichWithPinyinAndTranslation(chineseText: "好的。再见！")
        }
    }

    func reset() {
        conversationHistory = []
        if #available(iOS 26.0, *) {
            _session = nil
        }
    }
}

// MARK: - Custom Errors

enum FoundationModelsError: LocalizedError {
    case unavailable   // ← Dihapus associated value UnavailabilityReason (tidak ada di API ini)
    case sessionFailed
    case emptyResponse
    case unknown

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Apple Intelligence is not available on this device."
        case .sessionFailed:
            return "Could not create language model session."
        case .emptyResponse:
            return "Model returned an empty response."
        case .unknown:
            return "Unknown Foundation Models error."
        }
    }
}
