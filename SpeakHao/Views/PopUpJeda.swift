//
//  PopUp.swift
//  SpeakHao
//
//  Created by UpaCha on 03/05/26.
//
//

import SwiftUI

// MARK: - PopUp Model
struct PopUpData {
    let icon: String?
    let iconColor: Color
    let title: String
    let secondaryButtonTitle: String
    let primaryButtonTitle: String
    let secondaryAction: () -> Void
    let primaryAction: () -> Void
}

// MARK: - PopUp View
struct PopUpView: View {
    let alert: PopUpData
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = alert.icon {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(alert.iconColor)
            }
            Text(alert.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 8) {
                // Primary Button
                Button(action: alert.primaryAction) {
                    Text(alert.primaryButtonTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
//                .frame(width :220, height: 48)
//                .buttonStyle(GlassButtonStyle())
                // Secondary Button
                Button(action: alert.secondaryAction) {
                    Text(alert.secondaryButtonTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
//                .frame(width :220, height: 48)
//                .buttonStyle(GlassButtonStyle())
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 40)
    }
}

// MARK: - Overlay
struct OverlayPopUp: ViewModifier {
    @Binding var isPresented: Bool
    let alert: PopUpData
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                // Dimmed background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .zIndex(1)
                
                // Atur posisi PopUp
                PopUpView(alert: alert)
                    .zIndex(2)
//                .transition(.opacity.combined(with: .scale(scale: 0.95)))
//                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func customAlert(isPresented: Binding<Bool>, alert: PopUpData) -> some View {
        modifier(OverlayPopUp(isPresented: isPresented, alert: alert))
    }
}


