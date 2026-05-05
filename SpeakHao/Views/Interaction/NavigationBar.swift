//
//  NavigationBar.swift
//  SpeakHao
//
//  Created by Ririn Ayuning Riani on 04/05/26.
//
import SwiftUI

struct NavigationBar: View {
    
    var onBack: () -> Void
    var onHistory: () -> Void
    
    var body: some View {
        HStack {
            // Back Button
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                // 1. Efek Kaca Utama
                    .background(
                        .ultraThinMaterial, // Material paling tipis/transparan
                        in: Circle() // Bentuk background
                    )
                // 2. Border Kaca (Membuat tepian terlihat seperti potong kaca)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1))
                // 3. Shadow Halus (Memberikan efek kedalaman/mengapung)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                
            }
            
            Spacer()
            
            // History Button
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 14, weight: .medium))
                    Text("Riwayat")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.black.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            .fixedSize(horizontal: true, vertical: false)
            .hidden() //ngehide button riwayat
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
