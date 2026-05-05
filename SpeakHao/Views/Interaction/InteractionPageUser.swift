//
//  InteractionPageUser.swift
//  SpeakHao
//
//  Created by Ririn Ayuning Riani on 03/05/26.
//

import SwiftUI

struct InteractionPageUser: View {
    @State private var goToMainMenu = false
    @State private var showBackAlert = false
    @State private var isPressed = false
    @State private var pinyin = ""
    @State private var chinese = ""
    @State private var translation = ""
    
    var body: some View {
        NavigationStack {
        GeometryReader { geo in
            ZStack {
                InteractionSceneView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                // Interaction Container
                VStack(spacing: 12) {
                    // Top Bar
                    NavigationBar(
                        onBack: {
                            print("Back tapped")
                            showBackAlert = true
                        },
                        onHistory: {
                            print("History tapped")
                        }
                    )
                    
                    Spacer()
                    
                    // MARK: - Container D (Speech Bubble)
                    SpeechBubbleUser(
                        pinyinText: $pinyin,
                        chineseText: $chinese,
                        translationText: $translation
                    )
                    .padding(.bottom, 12)
                    
                    
                    // MARK: - Container P (button to repeat earlier question)
                    Button(action: {
                        print("Repeat tapped")
                    }) {
                        Text("Please repeat what you said earlier")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                    }
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    
                    
                    // MARK: - Container E (Action Bar)
                    ActionBar(
                        isPressed: $isPressed,
                        onMainAction: {
                            print("Mic tapped")
                        },
                        onSecondaryAction: {
                            print("Vocabulary tapped")
                        }, isCircle: true
                    )
                    {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, -50)
                    .padding(.top, -20)
                    
                }
            }
            .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
            .customAlert(
                isPresented: $showBackAlert,
                alert: PopUpData(
                    icon: "pause.circle",
                    iconColor: .black,
                    title: "Percakapan Dijeda",
                    secondaryButtonTitle: "Lanjutkan Percakapan",
                    primaryButtonTitle: "Keluar dari Percakapan",
                    secondaryAction: {
                        showBackAlert = false  // tutup alert, tetap di halaman
                    },
                    primaryAction: {
                        showBackAlert = false
                        goToMainMenu = true  // ← navigasi ke MainMenuSwipe
                    }
                )
            )
        }
        // Letakkan NavigationLink “invisible” di level paling atas dalam NavigationStack
            .background(
                NavigationLink(destination: InteractionNPCView(), isActive: $goToMainMenu) {
                    EmptyView()
                }
            )
        }
//        .navigationBarBackButtonHidden(true)
    }
}




 


// MARK: - Speech Bubble
struct SpeechBubbleUser: View {
    
    @Binding var pinyinText: String
    @Binding var chineseText: String
    @Binding var translationText: String
    
    var body: some View {
        
        let isEmpty = pinyinText.isEmpty &&
                      chineseText.isEmpty &&
                      translationText.isEmpty
        
        HStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                
                // TEXT AREA (SCROLLABLE)
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        if !pinyinText.isEmpty {
                            Text(pinyinText)
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        if !chineseText.isEmpty {
                            Text(chineseText)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        if !translationText.isEmpty {
                            Text(translationText)
                                .font(.system(size: 16).italic())
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                }
                .frame(maxHeight: 120) //scroll aktif kalau kepanjangan
                
                
                // ACTION BUTTONS
                HStack {
                    
                    // DELETE
                    Button(action: {
                        pinyinText = ""
                        chineseText = ""
                        translationText = ""
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(isEmpty ? .gray.opacity(0.8) : .gray)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                            .font(Font.system(size: 23))
                    }
                    .shadow(color: .black.opacity(0.2), radius: 0, x: 0, y: 0)
                    .disabled(isEmpty)
                    
                    
                    Spacer()
                    
                    
                    // SEND
                    Button(action: {
                        print("Send:", chineseText)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text("Kirim")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(isEmpty)
                }
            }
            .padding(14)
            .frame(maxWidth: 400)
            
            // BACKGROUND GLASS
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                }
            
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            
            // TAIL (KANAN BAWAH)
            .overlay(alignment: .bottomTrailing) {
                BubbleTail()
                    .fill(Color.white)
                    .frame(width: 40, height: 12)
                    .rotationEffect(.degrees(180))
                    .offset(x: -30, y: 10)
                }
            )
        }
        .padding(.horizontal, 20)
    }
}

struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.maxY),
            control2: CGPoint(x: rect.midX - rect.width * 0.10, y: rect.minY)
        )
        
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.midX + rect.width * 0.10, y: rect.minY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.30, y: rect.maxY)
        )
        
        path.closeSubpath()
        return path
    }
}





#Preview {
    InteractionPageUser()
}



//// Interaction Container
//VStack {
//    Spacer()
//
//    // container D
//    ZStack {
//        // bubble image
//
//        VStack {
//            // textview pinyin
//            // textview hanzi
//            // textview terjemahan
//            Text("")
//
//            // text action container
//            HStack {
//                // delete & send button
//            }
//        }
//    }
//}
