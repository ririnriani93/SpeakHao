//
//  InteractionNPCView.swift
//  SpeakHao
//
//  Created by M. TAQWA ADDARI on 03/05/26.
//


import SwiftUI

struct InteractionNPCView: View {
    @State private var isPressed = false
    @State private var showTranslation = false
    @State private var speechBubbleVisible = false
    @State private var navigateToInteractionPageUser = false
    @State private var showBackAlert = false
    @State private var goToMainMenu = false
    
    let pinyinText = "Lǐ nǚshì, zǎoshang hǎo, nín hǎo ma?"
    let chineseText = "李女士，早上好，您好吗？"
    let translationText = "Ms. Li, good morning, how are you?"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                InteractionSceneView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Custom Navigation Bar
                        NavigationBar(
                            onBack: {
                                print("Back tapped")
                                showBackAlert = true
                            },
                            onHistory: {
                                print("History tapped")
                            }
                        )
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 20)
                        
                        Spacer()
                        
                        // Speech Bubble NPC
                        SpeechBubbleView(
                            pinyinText: pinyinText,
                            chineseText: chineseText,
                            translationText: translationText,
                            showTranslation: $showTranslation
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, geometry.size.height * 0.2)
                        .opacity(speechBubbleVisible ? 1 : 0)
                        .offset(x: 5, y: -80)
                        
                        // Bottom Action Bar
                        BottomActionBar(
                            isPressed: $isPressed,
                            onAnswerTap: {
                                navigateToInteractionPageUser = true
                            },
                            onBookTap: {
                                print("Membuka glosarium...")
                            }
                        )
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
                                showBackAlert = false
                            },
                            primaryAction: {
                                showBackAlert = false
                                goToMainMenu = true  // ← navigasi ke MainMenuSwipe
                            }
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .ignoresSafeArea(.keyboard)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            
            // Navigasi ke InteractionPageUser
            .navigationDestination(isPresented: $navigateToInteractionPageUser) {
                InteractionPageUser()
            }
            
            // Navigasi ke MainMenuSwipe saat klik "Keluar dari Percakapan"
            .navigationDestination(isPresented: $goToMainMenu) {
                MainMenuSwipe()
            }
            
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                    speechBubbleVisible = true
                }
            }
        }
    }
}

struct CustomCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    InteractionNPCView()
}
