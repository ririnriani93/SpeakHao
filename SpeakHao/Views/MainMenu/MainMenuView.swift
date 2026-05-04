//
//  MainMenuView.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/1/26.
//

import SwiftUI

struct MainMenuView: View {
    
    let chapterNumber: Int
    let chapterTitle: String
    let chapterPreview: String
    let characterImage: String
    
    
    
    var body: some View {
        
        ZStack(alignment: .center) {
            //                // Background Image
            //                Image("Background")
            //                    .resizable()
            //                    .scaleEffect(1.7)
            //                    .offset(x: -140, y: -300)
            //                    .ignoresSafeArea()
            
            // Character Image
            VStack {
                Image(characterImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .scaleEffect(0.90)
                    .offset(x:0, y: 90)
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
                
                
                // Chapter Number
                Text("Chapter #\(chapterNumber) :")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
                
                // Title
                Text(chapterTitle)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
                    .kerning(0.4)
                    .padding(.top, 7)
                    .lineSpacing(7)
                
                // Preview
                Text(chapterPreview)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                    .lineSpacing(3)
                
                // Button
                //                    HStack {
                //                        Spacer()
                //
                //                        GlassButton(title: "Mulai Percakapan")
                //                            .frame(maxHeight: 48)
                //                            .frame(width: 220)
                //
                //                        Spacer()
                //                    }
                //                    .padding(.horizontal, 20)
                //                    .padding(.bottom, 90)
                
                
                HStack {
                    Spacer()
                    
                    Button ("Mulai Percakapan"){
                        // action yang terjadi
                    }
                    .frame(width :220, height: 48)
                    .buttonStyle(GlassButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
                
            }
            .frame(width: 348)
            
            // Page Control Dots
            //                    HStack(spacing: 8) {
            //                        Circle()
            //                            .fill(Color.white)
            //                            .frame(width: 8, height: 8)
            //
            //                        Circle()
            //                            .fill(Color.white.opacity(0.3))
            //                            .frame(width: 8, height: 8)
            //
            //                        Circle()
            //                            .fill(Color.white.opacity(0.3))
            //                            .frame(width: 8, height: 8)
            //                    }
            //                    .padding(.bottom, 40)
            //                    .frame(maxWidth: .infinity, alignment: .center)
        }
        .ignoresSafeArea()
    }
}



struct GlassButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.white)
        
            .frame(maxWidth: .infinity, maxHeight: .infinity) // biar backgrooundnya expand di luar scope configuration.label (sesuai sama frame yang ditetapin
        
            .background(
                RoundedRectangle(cornerRadius: 1000)
                    .fill(
                        Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255)
                    )
            )
        
            .overlay(
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
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        
    }
}

//
//struct GlassButton: View {
//    let title: String
//
//    var body: some View {
//        ZStack {
//            // Liquid Glass Background
//            RoundedRectangle(cornerRadius: 1000)
//                .fill(
//                    Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255)
//                )
//
//                .overlay(
//                    RoundedRectangle(cornerRadius: 1000)
//                        .strokeBorder(
//                            LinearGradient(
//                                stops: [
//                                    .init(color: .white.opacity(0.38), location: 0),
//                                    .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 1), location: 0.2),
//                                    .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 1), location: 0.8),
//                                    .init(color: .white.opacity(0.38), location: 1)],
//                                startPoint: UnitPoint(x: 0.4, y:0),
//                                endPoint: UnitPoint(x:0.6, y:1)),
//                            lineWidth: 1
//                        )
//                )
//
//            // Button Text
//            Text(title)
//                .font(.system(size: 17, weight: .medium))
//                .foregroundColor(.white)
//        }
//    }
//}

//#Preview {
//    MainMenuView(chapterNumber: <#T##Int#>, chapterTitle: <#T##String#>, chapterPreview: <#T##String#>, characterImage: <#T##String#>)
//}
