//
//  Splash.swift
//  SpeakHao
//
//  Created by UpaCha on 03/05/26.
//

import SwiftUI

// Akan berubah ke halaman selanjutnya setelah 0.2 detik
struct Splash: View {
    @State private var skenario = false
    
    var body: some View {
        Group {
            if skenario {
                MainMenuSwipe()
            } else {
                ZStack {
                    LinearGradient(gradient: Gradient( colors: [Color.orange, Color.white]), startPoint: .topTrailing, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    VStack {
                        Image("cth")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline:
                            .now() + 1.0) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    skenario = true
                                }
                            }
                }
            }
        }
    }
}

#Preview {
    Splash()
}
