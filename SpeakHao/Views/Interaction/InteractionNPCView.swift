//
//  InteractionNPCView.swift
//  SpeakHao
//
//  Created by M. TAQWA ADDARI on 03/05/26.
//

import SwiftUI

// MARK: - Main View
struct InteractionNPCView: View {
    @State private var isPressed = false
    @State private var showTranslation = false
    @State private var speechBubbleVisible = false
    
    let pinyinText = "Lǐ nǚshì, zǎoshang hǎo, nín hǎo ma?"
    let chineseText = "李女士，早上好，您好吗？"
    let translationText = "Ms. Li, good morning, how are you?"
    
    var body: some View {
        ZStack {
            InteractionSceneView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    TopBarView(onBackTap: {
                                print("Kembali ditekan")
                            }, onHistoryTap: {
                                print("Riwayat ditekan")
                            })
                            .padding(.top, geometry.safeAreaInsets.top > 0 ? 10 : 20)
                    
                    Spacer()
            
                    SpeechBubbleView(
                        pinyinText: pinyinText,
                        chineseText: chineseText,
                        translationText: translationText,
                        showTranslation: $showTranslation
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, geometry.size.height * 0.2)
                    .opacity(speechBubbleVisible ? 1 : 0)
                    .offset(x: 5, y: -80) // ini digunakan untuk mengatur posisi bubble
                    
                    BottomActionBar(
                        isPressed: $isPressed,
                        onAnswerTap: {
                            print("Mulai merekam suara...")
                            
                        },
                        onBookTap: {
                            print("Membuka glosarium...")
                        }
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                
            }
            .ignoresSafeArea(.keyboard) //
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                speechBubbleVisible = true
            }
        }
    }
}

struct CustomCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    InteractionNPCView()
}

