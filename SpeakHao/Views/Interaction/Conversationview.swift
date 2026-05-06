//
//  Conversationview.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/5/26.
//


import SwiftUI

struct ConversationView: View {

    @StateObject private var vm: InteractionViewModel

    init(scenario: NPCScenario = ScenarioRegistry.all[0]) {
        _vm = StateObject(wrappedValue: InteractionViewModel(scenario: scenario))
    }

    @State private var showNPCTranslation = false
    @State private var isHoldingMic       = false
    @State private var isPressed          = false
    @State private var bubbleVisible      = false
    @State private var isAnswering        = false

    @State private var showBackAlert      = false
    @State private var goToMainMenu       = false

    var body: some View {
        GeometryReader { geo in
            ZStack {

                InteractionSceneView()
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    topBar
                        .padding(.top, geo.safeAreaInsets.top > 0 ? 10 : 20)

                    Spacer()

                    if vm.isGenerating {
                        generatingIndicator
                            .padding(.bottom, 8)
                            .transition(.opacity)
                    }

                    npcBubble
                        .padding(.horizontal, 40)
                        .opacity(bubbleVisible ? 1 : 0)
                        .padding(.bottom, 12)

                    if isAnswering || isHoldingMic || !vm.pendingUserText.isEmpty {
                        userBubble
                            .padding(.bottom, 12)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    repeatButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)

                    if isAnswering {
                        ActionBar(
                            isPressed:         $isPressed,
                            onMainAction:      { },
                            onSecondaryAction: { },
                            isCircle:          true
                        ) {
                            micIcon
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !isHoldingMic { startHolding() }
                                }
                                .onEnded { _ in
                                    stopHolding()
                                }
                        )
                        .padding(.bottom, -50)
                        .padding(.top, -20)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))

                    } else {
                        answerBar
                            .padding(.bottom, -50)
                            .padding(.top, -20)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: isHoldingMic)
        .animation(.easeInOut(duration: 0.25), value: isAnswering)
        .animation(.easeInOut(duration: 0.2),  value: vm.isGenerating)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                bubbleVisible = true
            }
        }
        .onReceive(vm.transcribedTextPublisher) { text in
            vm.updateLiveTranscription(text)
        }
        .onChange(of: vm.isGenerating) { _, newValue in
            if !newValue {
                isAnswering = false
            }
        }
        // FIX 1: Pause semua saat showBackAlert berubah jadi true
        .onChange(of: showBackAlert) { _, isShowing in
            if isShowing {
                pauseAll()
            }
        }
        .customAlert(
            isPresented: $showBackAlert,
            alert: PopUpData(
                icon: "pause.circle",
                iconColor: .black,
                title: "Percakapan Dijeda",
                secondaryButtonTitle: "Lanjutkan Percakapan",
                primaryButtonTitle: "Keluar dari Percakapan",
                secondaryAction: {
                    // Tutup alert, tidak resume otomatis — user yang mulai lagi
                    showBackAlert = false
                },
                primaryAction: {
                    // Stop total sebelum keluar
                    stopAll()
                    showBackAlert = false
                    goToMainMenu  = true
                }
            )
        )
        .navigationDestination(isPresented: $goToMainMenu) {
            MainMenuSwipe2()
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

    // MARK: - Answer Bar

    private var answerBar: some View {
        VStack(spacing: 16) {
            ZStack {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isAnswering = true
                    }
                }) {
                    Text("Answer")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .scaleEffect(isPressed ? 0.92 : 1.0)

                HStack {
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 56, height: 56)
                            .background(Color.white, in: Circle())
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    }
                    .hidden()
                }
                .padding(.horizontal, 25)
            }
            .offset(x: 1, y: 30)

            Text("Tap and Hold to answer")
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.5))
                .padding(.bottom, 20)
                .offset(x: 1, y: 17)
                .hidden()
        }
        .padding(.top, 25)
        .background(
            ZStack {
                CustomCornerShape(corners: [.topLeft, .topRight], radius: 30)
                    .fill(.ultraThinMaterial)
                CustomCornerShape(corners: [.topLeft, .topRight], radius: 30)
                    .fill(Color.white.opacity(0.2))
                    .blendMode(.plusLighter)
            }
            .ignoresSafeArea()
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: {
                showBackAlert = true
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
            }

            Spacer()

            Button(action: { }) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
            }
            .hidden()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Bubble NPC

    private var npcBubble: some View {
        let lastNPC = vm.messages.last(where: { $0.role == .npc })
        return HStack {
            SpeechBubbleView(
                pinyinText:      lastNPC?.pinyinText  ?? "",
                chineseText:     lastNPC?.chineseText ?? "",
                translationText: lastNPC?.englishText ?? "",
                showTranslation: $showNPCTranslation
            )
            Spacer()
        }
    }

    // MARK: - Bubble User

    private var userBubble: some View {
        let liveText = vm.pendingUserText
        return SpeechBubbleUser(
            pinyinText:      .constant(""),
            chineseText:     Binding(get: { liveText }, set: { _ in }),
            translationText: .constant("")
        )
    }

    // MARK: - Repeat Button

    private var repeatButton: some View {
        Button(action: { vm.speakCurrentNPCMessage() }) {
            Text("Please repeat what you said earlier")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
        }
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
    }

    // MARK: - Mic Icon

    private var micIcon: some View {
        ZStack {
            if vm.isRecording {
                Circle()
                    .stroke(Color.red.opacity(0.35), lineWidth: 3)
                    .frame(width: 70, height: 70)
                    .scaleEffect(isHoldingMic ? 1.25 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                        value: isHoldingMic
                    )
            }
            Image(systemName: vm.isRecording ? "waveform" : "mic.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Generating Indicator

    private var generatingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 7, height: 7)
                    .scaleEffect(vm.isGenerating ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.18),
                        value: vm.isGenerating
                    )
            }
            Text("Answering...")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.black.opacity(0.35)))
    }

    // MARK: - Helpers

    private func startHolding() {
        isHoldingMic = true
        isPressed    = true
        vm.startRecording()
    }

    private func stopHolding() {
        isHoldingMic = false
        isPressed    = false
        vm.stopRecording()
        vm.sendUserResponse()
    }

    /// Hentikan semua aktivitas audio sementara (saat pop up jeda muncul)
    private func pauseAll() {
        // Stop mic kalau lagi dipakai
        if vm.isRecording {
            vm.stopRecording()
            isHoldingMic = false
            isPressed    = false
        }
        // Stop TTS / NPC speaking
        vm.stopSpeaking()
    }

    /// Hentikan semua aktivitas secara permanen (saat user memilih keluar)
    private func stopAll() {
        if vm.isRecording {
            vm.stopRecording()
        }
        vm.stopSpeaking()
        // Reset state UI supaya bersih
        isHoldingMic = false
        isPressed    = false
        isAnswering  = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ConversationView()
    }
}
