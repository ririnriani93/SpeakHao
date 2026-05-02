//
//  InteractionSceneView.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/2/26.
//

import SwiftUI

struct InteractionSceneView: View {
    var body: some View {
        ZStack {
            // Background Image - Zoomed (melebar)
            // ADJUST: scaleEffect(1.2) untuk zoom
            // ADJUST: offset(x: 0, y: 0) untuk posisi
            Image("Background")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.7)
                .offset(x: -140, y: -250)
                .ignoresSafeArea()

            // Character Image
            // ADJUST: scaleEffect(0.75) untuk ukuran
            // ADJUST: offset(x: -80, y: 136) untuk posisi
            VStack {
                Image("character_idle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .scaleEffect(0.98)
                    .offset(x: -85, y: 152)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    InteractionSceneView()
}
