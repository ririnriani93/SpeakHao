//
//  interactionviewmodels.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//
import Foundation
import Combine

@MainActor
class InteractionViewModel: ObservableObject {

    // MARK: - Services
    private let speechRecognition = SpeechRecognitionService()
    private let speechSynthesis = SpeechSynthesisService()
    private let naturalLanguage = NaturalLanguageService()
    private let foundationModels: FoundationModelsService

    // MARK: - Published State

    @Published var messages: [ConversationMessage] = []
    @Published var pendingUserText = ""        // Live STT transcription shown while recording
    @Published var isRecording = false
    @Published var isNPCSpeaking = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var lastAnalysis: LanguageAnalysisResult?

    // MARK: - Init

    // ⚠️ FIX: NPCScenario.morningGreeting adalah @MainActor-isolated static property.
    //         Default parameter value tidak bisa langsung referensikan ini dari nonisolated context.
    //         Solusi: hilangkan default value dan buat convenience init terpisah,
    //         atau jadikan parameter tanpa default (caller selalu pass .morningGreeting secara eksplisit).
    init(scenario: NPCScenario) {
        self.foundationModels = FoundationModelsService(scenario: scenario)
        // Show NPC opening line
        messages.append(scenario.initialMessage)
        // NPC speaks the opening line automatically
        Task {
            // ⚠️ FIX: Task.sleep bisa throw — harus pakai try? agar tidak crash
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay for UX
            speakMessage(scenario.initialMessage)
        }
    }

    // MARK: - Recording Control

    func startRecording() {
        guard !isRecording else { return }
        // Stop NPC if still talking
        speechSynthesis.stopSpeaking()

        Task {
            do {
                try await speechRecognition.startRecording(useChinese: true)
                isRecording = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        speechRecognition.stopRecording()
        isRecording = false
        pendingUserText = speechRecognition.transcribedText
    }

    // Real-time transcription update (bind to SpeechRecognitionService.transcribedText)
    func updateLiveTranscription(_ text: String) {
        pendingUserText = text
    }

    // MARK: - Send / Confirm Response

    /// Called when user taps "Kirim" — finalizes their spoken response
    func sendUserResponse() {
        let text = pendingUserText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // 1. Natural Language analysis
        let analysis = naturalLanguage.analyze(
            userText: text,
            expectedKeywords: NPCScenario.morningGreeting.expectedKeywords
        )
        lastAnalysis = analysis

        // 2. Build user message (detected language shown in pinyin/english slots for test)
        let langLabel = analysis.detectedLanguage ?? "unknown"
        let userMessage = ConversationMessage(
            role: .user,
            chinese: text,
            pinyin: "Lang: \(langLabel) · \(analysis.tokens.prefix(5).joined(separator: " "))",
            english: analysis.isRelevantToContext ? "✓ On topic" : "⚠ Off topic"
        )
        messages.append(userMessage)
        pendingUserText = ""

        // 3. Generate NPC response via Foundation Models
        isGenerating = true
        Task {
            let npcReply = await foundationModels.generateResponse(to: text)
            isGenerating = false
            messages.append(npcReply)
            speakMessage(npcReply)
        }
    }

    func deleteLastUserInput() {
        pendingUserText = ""
        if messages.last?.role == .user {
            messages.removeLast()
        }
    }

    // MARK: - TTS

    func speakMessage(_ message: ConversationMessage) {
        // Speak Chinese characters for NPC, English for self-check
        let textToSpeak = message.chineseText
        let language = message.role == .npc ? "zh-CN" : "en-US"
        speechSynthesis.speak(textToSpeak, language: language)
        isNPCSpeaking = speechSynthesis.isSpeaking
    }

    func speakCurrentNPCMessage() {
        guard let lastNPC = messages.last(where: { $0.role == .npc }) else { return }
        speakMessage(lastNPC)
    }

    func reset() {
        messages = []
        foundationModels.reset()
        pendingUserText = ""
        errorMessage = nil
        speechSynthesis.stopSpeaking()
        speechRecognition.stopRecording()
    }

    // MARK: - Combine Binding Sink

    /// Call this in the view's .onReceive to forward live STT to pendingUserText
    var transcribedTextPublisher: Published<String>.Publisher {
        speechRecognition.$transcribedText
    }
}
