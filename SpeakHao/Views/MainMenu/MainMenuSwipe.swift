//
//  MainMenuSwipe.swift
//  SpeakHao
//
//  Created by Devi Jayanti Sujata on 02/05/26.
//

import SwiftUI

struct MainMenuSwipe: View {
    
    @State private var showPopUp = false
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            
            // Background Image
            Image("Background")
                .resizable()
                .scaleEffect(1.7)
                .offset(x: -140, y: -300)
                .ignoresSafeArea()
            
            
            TabView {
                MainMenuView(
                    chapterNumber: 1,
                    chapterTitle: "Self Introduction at New Company",
                    chapterPreview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel dolor vitae libero facilisis vestibulum. Integer sit amet turpis arcu. Nunc tempor nibh molestie elit mattis tempus. Suspendisse diam est, tristique ut nibh in Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    characterImage: "character_idle"
                )
                
                ZStack(alignment: .center){
                    MainMenuView(
                        chapterNumber: 2,
                        chapterTitle: "First Meeting With The Team",
                        chapterPreview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel dolor vitae libero facilisis vestibulum. Integer sit amet turpis arcu. Nunc tempor nibh molestie elit mattis tempus. Suspendisse diam est, tristique ut nibh in Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        characterImage: "character_idle"
                    )
                    
                    PopUpLocked()
                                       
                }
//                showPopUp()
                
                ZStack(alignment: .center){
                    MainMenuView(
                        chapterNumber: 3,
                        chapterTitle: "Progress Update to Client",
                        chapterPreview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel dolor vitae libero facilisis vestibulum. Integer sit amet turpis arcu. Nunc tempor nibh molestie elit mattis tempus. Suspendisse diam est, tristique ut nibh in Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        characterImage: "character_idle"
                    )
                    PopUpLocked()
                }
            }
                
            .tabViewStyle(.page(indexDisplayMode: .always)) //page controls udah ada disini
            .ignoresSafeArea()
                
            
//            if showPopUp {
//                Color.black.opacity(0.5)
//                    .ignoresSafeArea()
//            }
            
            
        
            
        }
    }
}

struct PopUpLocked : View {
    var body: some View{
        Color.black.opacity(0.5)
            .ignoresSafeArea()
        
        // Pop Up Locked
        VStack (alignment: .center, spacing: 0){
            Image(systemName: "exclamationmark.lock.fill")
                .font(.system(size:60, weight: .bold))
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 0)
            
            Text("Chapter Terkunci")
                .font(.system(size: 28).weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .frame(width: 295, alignment: .top)
                .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y:0)
                .padding(.top, 7)
            
            Text("Selesaikan percakapan pada chapter sebelumnya untuk mengakses chapter ini!")
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .frame(width: 295, alignment: .top)
                .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y:0)
                .padding(.top, 5)
        }
        .frame(width: 348, height: 236)
//                    .background(Color.white)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 35)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.7), location: 0),
                            .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 0), location: 0.2),
                            .init(color: Color(.displayP3, red: 0/255, green: 100/255, blue: 255/255, opacity: 0), location: 0.8),
                            .init(color: .white.opacity(0.7), location: 1)],
                        startPoint: UnitPoint(x: 0.4, y:0),
                        endPoint: UnitPoint(x:0.6, y:1)),
                    lineWidth: 1
                )
        )
        .cornerRadius(35)
        .padding(27)
        .shadow(color: Color.black.opacity(0.35), radius: 5, x:0, y:0) 
    }
}

#Preview {
    MainMenuSwipe()
}
