//
//  TopBarView.swift
//  SpeakHao
//
//  Created by M. TAQWA ADDARI on 04/05/26.
//

import SwiftUI

struct TopBarView: View {
  
    var onBackTap: () -> Void = {}
    var onHistoryTap: () -> Void = {}
    
    var body: some View {
        HStack {
           
            Button(action: onBackTap) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
            }
            
            Spacer()
            
           
            Button(action: onHistoryTap) {
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
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        TopBarView()
    }
}
