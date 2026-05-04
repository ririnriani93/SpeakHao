// InteractionPageNpc.swift
// SpeakHao
// Interactive NPC conversation screen — fully wired to:
//   • SpeechRecognitionService (Speech framework STT)
//   • SpeechSynthesisService (AVSpeechSynthesizer TTS)
//   • NaturalLanguageService (NL framework analysis)
//   • FoundationModelsService (on-device LLM / fallback)
//
// ⚠️ JIKA ADA ERROR "Cannot find type in scope":
//    Pilih semua file Services/ dan ViewModels/ di Xcode →
//    File Inspector (panel kanan) → pastikan target "SpeakHao" dicentang.

import SwiftUI

struct InteractionPageNpc: View {
    
    @StateObject private var vm = InteractionViewModel(scenario: .morningGreeting)
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var isHoldingMic = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                conversationArea
                pendingInputArea
                micPanel
            }
        }
        // Forward live STT into viewModel
        .onReceive(vm.transcribedTextPublisher) { text in
            vm.updateLiveTranscription(text)
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            glassButton(icon: "chevron.left") {}
            Spacer()
            glassButton(icon: "speaker.wave.2.fill", label: "NPC") {
                vm.speakCurrentNPCMessage()
            }
            glassButton(icon: "clock.arrow.circlepath", label: "Riwayat") {}
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
    
    // MARK: - Conversation Scroll Area
    
    private var conversationArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(vm.messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }
                    
                    if vm.isGenerating {
                        typingIndicator
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onAppear { scrollProxy = proxy }
            .onChange(of: vm.messages.count) { _, _ in
                if let last = vm.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: vm.isGenerating) { _, _ in
                withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
            }
        }
    }
    
    // MARK: - Message Bubble
    
    @ViewBuilder
    private func messageBubble(_ message: ConversationMessage) -> some View {
        let isNPC = message.role == .npc
        
        HStack {
            if !isNPC { Spacer(minLength: 48) }
            
            VStack(alignment: isNPC ? .leading : .trailing, spacing: 5) {
                // Pinyin / metadata line
                Text(message.pinyinText)
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.45))
                
                // Chinese characters (main)
                Text(message.chineseText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                
                // English translation / status
                Text(message.englishText)
                    .font(.system(size: 14).italic())
                    .foregroundColor(Color(red: 0, green: 0.53, blue: 1))
                
                // Replay NPC audio button
                if isNPC {
                    Button {
                        vm.speakMessage(message)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 11))
                            Text("Listen")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color(white: 0.5))
                        .padding(.top, 2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: isNPC ? .leading : .trailing)
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            
            if isNPC { Spacer(minLength: 48) }
        }
    }
    
    // MARK: - Typing Indicator
    
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(white: 0.5))
                        .frame(width: 7, height: 7)
                        .scaleEffect(vm.isGenerating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.18),
                            value: vm.isGenerating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
            .id("typing")
            
            Spacer(minLength: 48)
        }
        .padding(.horizontal, 0)
    }
    
    // MARK: - Pending Input (live STT + confirm/delete)
    
    @ViewBuilder
    private var pendingInputArea: some View {
        if !vm.pendingUserText.isEmpty {
            VStack(spacing: 10) {
                // Live transcription preview
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            if vm.isRecording {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 7, height: 7)
                                Text("Recording...")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.5))
                            } else {
                                Text("Your response:")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        
                        Text(vm.pendingUserText)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(3)
                    }
                    Spacer()
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: vm.deleteLastUserInput) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                    }
                    
                    Button(action: vm.sendUserResponse) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16))
                            Text("Kirim")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(Color(red: 0, green: 0.57, blue: 1)))
                    }
                    .disabled(vm.isGenerating)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(white: 0.08))
        }
    }
    
    // MARK: - Mic Panel (hold to speak)
    
    private var micPanel: some View {
        VStack(spacing: 12) {
            ZStack {
                // Pulse ring when recording
                if vm.isRecording {
                    Circle()
                        .stroke(Color(red: 0, green: 0.57, blue: 1).opacity(0.3), lineWidth: 3)
                        .frame(width: 90, height: 90)
                        .scaleEffect(isHoldingMic ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                   value: isHoldingMic)
                }
                
                Circle()
                    .fill(vm.isRecording
                          ? Color.red
                          : Color(red: 0, green: 0.57, blue: 1))
                    .frame(width: 70, height: 70)
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                    .scaleEffect(isHoldingMic ? 0.92 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isHoldingMic)
                
                Image(systemName: vm.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHoldingMic {
                            isHoldingMic = true
                            vm.startRecording()
                        }
                    }
                    .onEnded { _ in
                        isHoldingMic = false
                        vm.stopRecording()
                    }
            )
            
            Text(vm.isRecording
                 ? "Lepas untuk berhenti"
                 : vm.isNPCSpeaking
                   ? "NPC sedang berbicara..."
                   : "Tekan dan tahan untuk jawab")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.6))
            
            // Debug: NL analysis result (remove in production)
            if let analysis = vm.lastAnalysis {
                Text("Lang: \(analysis.detectedLanguage ?? "?") · \(analysis.isRelevantToContext ? "On topic ✓" : "Off topic ⚠")")
                    .font(.system(size: 11))
                    .foregroundColor(Color(white: 0.35))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(white: 0.1))
        .cornerRadius(24)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Helpers
    
    private func glassButton(icon: String, label: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: label != nil ? 6 : 0) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                if let label {
                    Text(label)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundColor(Color(white: 0.1))
            .padding(.horizontal, label != nil ? 20 : 0)
            .frame(width: label != nil ? nil : 48, height: 48)
            .background(Capsule().fill(Color.white.opacity(0.65)))
            .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        }
    }
}

#Preview {
    InteractionPageNpc()
}
