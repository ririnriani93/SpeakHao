//
//  ActionBar.swift
//  SpeakHao
//
//  Created by Ririn Ayuning Riani on 04/05/26.
//
import SwiftUI

// MARK: - Main Action Button (Reusable)
struct MainActionButton<Content: View>: View {
    
    @Binding var isPressed: Bool
    var action: () -> Void
    var isCircle: Bool
    var content: () -> Content
    
    var body: some View {
        Button(action: action) {
            content()
                .padding(.horizontal, isCircle ? 0 : 28)
                .padding(isCircle ? 20 : 12)
                .frame(
                    width: isCircle ? 70 : nil,
                    height: isCircle ? 70 : nil
                )
        }
        
        .buttonStyle(GlassButtonStyle1(isCircle: isCircle))
//        .buttonStyle(GlassButtonStyle())
        
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

struct CustomCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Bottom Action Bar
struct ActionBar<MainContent: View>: View {
    
    @Binding var isPressed: Bool
    
    var onMainAction: () -> Void
    var onSecondaryAction: () -> Void
    
    var isCircle: Bool
    
    var mainContent: () -> MainContent
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                
                // Main Button
                MainActionButton(
                    isPressed: $isPressed,
                    action: onMainAction,
                    isCircle: isCircle,
                    content: mainContent
                )
                
                // Secondary Button (kanan)
                HStack {
                    Spacer()
                    
                    Button(action: onSecondaryAction) {
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: 70, height: 70)
                            .background(Color.white, in: Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .hidden() // ngehide button dictionary
                }
                .padding(.horizontal, 30)
                .padding(.bottom, -30)
                .padding(.top, 20)
            }
            
            // Hint Text
            Text("Tekan dan tahan untuk jawab")
                .font(.system(size: 13))
                .italic()
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
        }
        .padding(.bottom, 30)
        .background(
            ZStack {
                CustomCornerShape(corners: [.topLeft, .topRight], radius: 30)
                    .fill(.ultraThinMaterial)
                CustomCornerShape(corners: [.topLeft, .topRight], radius: 30)
                    .fill(Color.white.opacity(0.2))
                    .blendMode(.plusLighter)
            }
            .ignoresSafeArea()
        )
    }
}


// MARK: - Button Style
struct GlassButtonStyle1 : ButtonStyle {
    var isCircle: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.white)
        
            .frame(width: 100, height: 100) // biar backgrooundnya expand di luar scope configuration.label (sesuai sama frame yang ditetapin
        
            .background(
                Group {
                    if isCircle {
                        Circle()
                            .fill(
                                Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 1000)
                            .fill(
                                Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255)
                            )
                    }
                }
            )
        
            .overlay(
                Group {
                    if isCircle {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.38), location: 0),
                                        .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 1), location: 0.2),
                                        .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 1), location: 0.8),
                                        .init(color: .white.opacity(0.38), location: 1)],
                                    startPoint: UnitPoint(x: 0.4, y:0),
                                    endPoint: UnitPoint(x:0.6, y:1)),
                                lineWidth: 1
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 1000)
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.38), location: 0),
                                        .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 1), location: 0.2),
                                        .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 1), location: 0.8),
                                        .init(color: .white.opacity(0.38), location: 1)],
                                    startPoint: UnitPoint(x: 0.4, y:0),
                                    endPoint: UnitPoint(x:0.6, y:1)),
                                lineWidth: 1
                            )
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .padding(.bottom, -30)
            .padding(.top,20)
            
    }
}
