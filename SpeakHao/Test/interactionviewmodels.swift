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

    // MARK: - State
    @Published var messages: [ConversationMessage] = []
    @Published var pendingUserText = ""
    @Published var isRecording = false
    @Published var isNPCSpeaking = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var lastAnalysis: LanguageAnalysisResult?

    private var scenario: NPCScenario

    // MARK: - Init

    init(scenario: NPCScenario) {
        self.scenario = scenario
        self.foundationModels = FoundationModelsService(scenario: scenario)
        messages.append(scenario.initialMessage)
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            speakMessage(scenario.initialMessage)
        }
    }

    // MARK: - Recording

    func startRecording() {
        guard !isRecording else { return }
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

    func updateLiveTranscription(_ text: String) {
        pendingUserText = text
    }

    // MARK: - Send Response

    func sendUserResponse() {
        let text = pendingUserText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // NL analysis — expectedKeywords kosong karena tidak ada stage constraint lagi.
        // NaturalLanguageService tetap dipakai untuk sentiment detection.
        let analysis = naturalLanguage.analyze(userText: text)
        lastAnalysis = analysis

        let langLabel = analysis.detectedLanguage ?? "unknown"
        let userMessage = ConversationMessage(
            role: .user,
            chinese: text,
            pinyin: "Lang: \(langLabel) · \(analysis.tokens.prefix(5).joined(separator: " "))",
            english: analysis.isRelevantToContext ? "✓ On topic" : "⚠ Off topic"
        )
        messages.append(userMessage)
        pendingUserText = ""

        isGenerating = true
        Task {
            let npcReply = await foundationModels.generateResponse(
                to: text,
                languageAnalysis: analysis
            )
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
        let language = message.role == .npc ? "zh-CN" : "en-US"
        speechSynthesis.speak(message.chineseText, language: language)
        isNPCSpeaking = speechSynthesis.isSpeaking
    }

    func speakCurrentNPCMessage() {
        guard let lastNPC = messages.last(where: { $0.role == .npc }) else { return }
        speakMessage(lastNPC)
    }

    /// Stop TTS segera — dipanggil saat jeda atau keluar percakapan
    func stopSpeaking() {
        speechSynthesis.stopSpeaking()
        isNPCSpeaking = false
    }

    func reset() {
        messages = []
        foundationModels.reset()
        pendingUserText = ""
        errorMessage = nil
        speechSynthesis.stopSpeaking()
        speechRecognition.stopRecording()
    }

    // MARK: - Publisher

    var transcribedTextPublisher: Published<String>.Publisher {
        speechRecognition.$transcribedText
    }
}
