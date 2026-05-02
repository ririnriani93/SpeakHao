//
//  MainMenuView.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/1/26.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            Image("Background")
                .resizable()
                .ignoresSafeArea()

            // Character Image
            VStack {
                Image("character_idle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .scaleEffect(0.75)
                
                Spacer()
            }
            .ignoresSafeArea()

            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 73/255, green: 138/255, blue: 186/255, opacity: 0), location: 0),
                    .init(color: Color(red: 226/255, green: 90/255, blue: 0/255, opacity: 0.43), location: 0.3),
                    .init(color: Color(red: 204/255, green: 58/255, blue: 0/255, opacity: 0.9), location: 0.65)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content Layer
            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // Chapter Title
                Text("Chapter #1 :")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
                    .padding(.leading, 20)

                // Subtitle
                Text("Self Introduction at New Company")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
                    .padding(.leading, 20)
                    .padding(.top, 7)
                    .lineSpacing(7)

                // Description
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel dolor vitae libero facilisis vestibulum. Integer sit amet turpis arcu. Nunc tempor nibh molestie elit mattis tempus. Suspendisse diam est, tristique ut nibh in Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    .lineSpacing(3)

                Spacer()
                    .frame(height: 20)

                // Glass Button
                HStack {
                    Spacer()
                    
                    GlassButton(title: "Mulai Percakapan")
                        .frame(height: 48)
                        .frame(maxWidth: 180)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Page Control Dots
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .ignoresSafeArea()
    }
}

struct GlassButton: View {
    let title: String

    var body: some View {
        ZStack {
            // Liquid Glass Background
            RoundedRectangle(cornerRadius: 1000)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 80/255, green: 170/255, blue: 255/255, opacity: 0.9),
                            Color(red: 120/255, green: 190/255, blue: 255/255, opacity: 0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 1000)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )
                .shadow(color: Color(red: 80/255, green: 170/255, blue: 255/255, opacity: 0.5), radius: 15, x: 0, y: 8)

            // Button Text
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MainMenuView()
}
