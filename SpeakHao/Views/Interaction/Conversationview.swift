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

                    if isHoldingMic || !vm.pendingUserText.isEmpty {
                        userBubble
                            .padding(.bottom, 12)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }


                    repeatButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
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
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: isHoldingMic)
        .animation(.easeInOut(duration: 0.2),  value: vm.isGenerating)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                bubbleVisible = true
            }
        }
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
            Button(action: { }) {
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
                    Text("Riwayat")
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

    // Bubble NPC

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

    // Bubble User

    private var userBubble: some View {
        let liveText = vm.pendingUserText
        return SpeechBubbleUser(
            pinyinText:      .constant(""),
            chineseText:     Binding(get: { liveText }, set: { _ in }),
            translationText: .constant("")
        )
    }

    // Repeat Button

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

    // Mic Icon

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

    // Generating Indicator

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
            Text("NPC sedang membalas...")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.black.opacity(0.35)))
    }

    // Helpers

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
}

// Preview

#Preview {
    NavigationStack {
        ConversationView()
    }
}
