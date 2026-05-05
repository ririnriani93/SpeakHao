//
//  SpeechBubbleView.swift
//  SpeakHao
//
//  Created by M. TAQWA ADDARI on 04/05/26.
//

import SwiftUI

struct SpeechBubbleView: View {
    let pinyinText: String
    let chineseText: String
    let translationText: String
    @Binding var showTranslation: Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text(pinyinText)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
            
            Text(chineseText)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            if showTranslation {
                Text(translationText)
                    .font(.system(size: 14).italic())
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Button(action: { withAnimation { showTranslation = true } }) {
                    Text("Lihat terjemahan")
                        .font(.system(size: 12))
                        .underline()
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .frame(maxWidth: 305, alignment: .leading)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(alignment: .topLeading) {
            BubbleTailView()
                .fill(Color.white)
                .frame(width: 40, height: 16)
                .offset(x: 35, y: -16)
        }
    }
}


struct BubbleTailView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                      control1: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY),
                      control2: CGPoint(x: rect.midX - rect.width * 0.2, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                      control1: CGPoint(x: rect.midX + rect.width * 0.2, y: rect.minY),
                      control2: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 30) {
        
        SpeechBubbleView(
            pinyinText: "Nǐ hǎo.",
            chineseText: "你好。",
            translationText: "Halo.",
            showTranslation: .constant(false)
        )
        
       
        SpeechBubbleView(
            pinyinText: "Wǒ hěn gāoxìng rènshi nǐ, nǐ hǎo ma? Jīntiān de tiānqì hěn hǎo.",
            chineseText: "我很高兴认识你，你好吗？今天的天气很好。",
            translationText: "Saya sangat senang bertemu denganmu, apa kabarmu? Cuaca hari ini sangat bagus.",
            showTranslation: .constant(true) // Set true untuk melihat teks terjemahan yang panjang
        )
        
       
        SpeechBubbleView(
            pinyinText: "Lǐ nǚshì, zǎoshang hǎo.",
            chineseText: "李女士，早上好。",
            translationText: "Ms. Li, selamat pagi.",
            showTranslation: .constant(false)
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(uiColor: .secondarySystemBackground))
}
