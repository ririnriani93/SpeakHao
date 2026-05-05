//
//  ButtonActionBar.swift
//  SpeakHao
//
//  Created by M. TAQWA ADDARI on 04/05/26.
//

import SwiftUI

struct BottomActionBar: View {
    @Binding var isPressed: Bool
    var onAnswerTap: () -> Void = {}
    var onBookTap: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Button Utama: Jawab
                Button(action: {}) {
                    Text("Jawab")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in
                            isPressed = false
                            onAnswerTap()
                        }
                )
                
                // Button Samping: Kamus/Buku
                HStack {
                    Spacer()
                    Button(action: onBookTap) {
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 56, height: 56)
                            .background(Color.white, in: Circle())
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 25)
                
            }
            .offset(x: 1, y: 15)
            
            
            Text("Tekan dan tahan untuk jawab")
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.5))
                .padding(.bottom, 20)
                .offset(x: 1, y: 17)
            
        }
        .padding(.top, 25)
        .background(
           
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .background(.ultraThinMaterial)
                .clipShape(CustomCorner(radius: 35, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
        )
    }
}


#Preview {
    BottomActionBar(isPressed: .constant(false))
        .background(Color.gray)
}
