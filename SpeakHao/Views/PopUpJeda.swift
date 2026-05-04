//
//  PopUp.swift
//  SpeakHao
//
//  Created by UpaCha on 03/05/26.
//

import SwiftUI

struct PopUpJeda: View {
    @State var showingPopUp : Bool = false
    
    var body : some View {
        ZStack {
            // tampilan utama itu halaman interaksi
            VStack{
                Text("Harusnya ini nyangkut ke antara halaman interaksi user atau interaksi npc. Tapi upa bingung biar dia nyangkut ke tombol 'back' itu.")
                    .padding().font(.system(size: 17, weight: .bold))
                
                Button("tombol back") {
                    showingPopUp = true
                }
            }
            // Pop Up Jeda
            if showingPopUp {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .alert("Percakapan dijeda",
                           isPresented: $showingPopUp) {
                        Button("Keluar dari percakapan", role: .destructive) {
                            //navigateToMainMenu = true
                        }
                        Button("Lanjutkan percakapan", role: .cancel) {
                            // otomatis menutup alert
                        }
                    } message: {
                        Text("Apakah Anda ingin keluar dari percakapan atau melanjutkan?")
                    }
            }
        }
    }
}

#Preview {
    PopUpJeda()
}

