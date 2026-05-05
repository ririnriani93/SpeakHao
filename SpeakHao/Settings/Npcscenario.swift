//
//  Npcscenario.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/5/26.
//
import Foundation
 
// MARK: - Conversation Stage
 
/// Satu "babak" dalam percakapan NPC.
/// NPC tetap di stage ini sampai user menyebut salah satu transitionKeywords,
/// lalu maju ke stage berikutnya. Stage terakhir (isTerminal = true) menutup percakapan.
struct ConversationStage {
    /// Instruksi khusus stage ini — ditambahkan ke baseSystemPrompt saat memanggil model
    let stagePrompt: String
 
    /// Pesan pembuka NPC saat stage ini dimulai (nil = model generate sendiri)
    let openingMessage: ConversationMessage?
 
    /// Kata kunci yang memicu transisi ke stage berikutnya.
    /// Jika kosong, NPC tidak akan maju dari stage ini.
    let transitionKeywords: [String]
 
    /// Apakah ini stage terakhir?
    let isTerminal: Bool
 
    /// Pesan penutup statis (opsional). Jika nil, model yang generate.
    let closingMessage: ConversationMessage?
}
 
// MARK: - NPC Scenario
 
struct NPCScenario {
    let id: String
    let title: String
    /// Deskripsi chapter untuk ditampilkan di menu
    let description: String
 
    /// System prompt dasar, dipakai di semua stage
    let baseSystemPrompt: String
 
    /// Urutan stage — percakapan berjalan dari index 0 sampai habis
    let stages: [ConversationStage]
 
    /// Index stage aktif saat ini
    var currentStageIndex: Int = 0
    
    /// Explicit initializer
    init(id: String, title: String, description: String = "", baseSystemPrompt: String, stages: [ConversationStage]) {
        self.id = id
        self.title = title
        self.description = description
        self.baseSystemPrompt = baseSystemPrompt
        self.stages = stages
        self.currentStageIndex = 0
    }
 
    var currentStage: ConversationStage {
        stages[min(currentStageIndex, stages.count - 1)]
    }
 
    var initialMessage: ConversationMessage {
        stages[0].openingMessage ?? ConversationMessage(
            role: .npc,
            chinese: "你好！",
            pinyin: "Nǐ hǎo!",
            english: "Hello!"
        )
    }
 
    /// Kata kunci yang relevan dari stage saat ini (dipakai NaturalLanguageService)
    var expectedKeywords: [String] {
        currentStage.transitionKeywords
    }
 
    var isFinished: Bool {
        currentStage.isTerminal
    }
 
     /// Cek apakah user input memenuhi syarat transisi stage.
     /// Returns true jika stage berhasil maju.
     ///
     /// Menggunakan multiple detection strategies:
     /// 1. Substring matching pada keywords (case-insensitive)
     /// 2. Partial character matching untuk keywords Chinese
     mutating func advanceIfNeeded(for userText: String) -> Bool {
         guard !isFinished else { return false }
         let lower = userText.lowercased()
         let keywords = currentStage.transitionKeywords
         guard !keywords.isEmpty else { return false }
  
         // Strategy 1: Direct substring matching (case-insensitive)
         let hasDirectMatch = keywords.contains(where: { keyword in
             lower.contains(keyword.lowercased())
         })
         
         // Strategy 2: For Chinese keywords, check character-by-character
         let hasChineseMatch = keywords.contains(where: { keyword in
             // Check if keyword contains Chinese characters
             let hasChineseChars = keyword.contains { $0.isLetter && keyword.unicodeScalars.first.map { $0.value > 0x4E00 && $0.value < 0x9FFF } ?? false }
             if hasChineseChars {
                 // For Chinese, check if all characters in keyword appear in userText (in order or not)
                 var textIndex = userText.startIndex
                 for keywordChar in keyword {
                     if keywordChar.isLetter && keywordChar.unicodeScalars.first.map({ $0.value > 0x4E00 && $0.value < 0x9FFF }) ?? false {
                         // This is a Chinese character, look for it
                         if let found = userText[textIndex...].firstIndex(of: keywordChar) {
                             textIndex = userText.index(after: found)
                         } else {
                             return false
                         }
                     }
                 }
                 return true
             }
             return false
         })
  
         let shouldAdvance = hasDirectMatch || hasChineseMatch
         if shouldAdvance && currentStageIndex < stages.count - 1 {
             currentStageIndex += 1
             return true
         }
         return false
     }
 
    mutating func reset() {
        currentStageIndex = 0
    }
}
 
// MARK: - ScenarioProvider Protocol
 
/// Setiap file skenario harus conform protocol ini.
/// FoundationModelsService memanggil fallbackResponse & pinyinMap lewat protocol ini,
/// sehingga service tidak perlu switch atas scenario.id.
protocol ScenarioProvider {
    /// Definisi lengkap skenario (stages, prompts, opening message)
    static var scenario: NPCScenario { get }
 
    /// Kamus pinyin + terjemahan untuk frasa statis NPC di skenario ini.
    /// Key: teks Chinese. Value: (pinyin, english)
    static var pinyinMap: [String: (String, String)] { get }
 
    /// Fallback rule-based response jika Foundation Models tidak tersedia.
    /// Implementasi boleh pakai stageIndex untuk memilih balasan per babak.
    static func fallbackResponse(stageIndex: Int, userText: String) -> ConversationMessage
}
 
// MARK: - ScenarioProvider Default Helper
 
extension ScenarioProvider {
    /// Buat ConversationMessage NPC dengan lookup otomatis ke pinyinMap.
    /// Jika teks tidak ada di map, pinyin diisi "—" dan english diisi placeholder.
    static func makeNPCMessage(
        chinese: String,
        isClosing: Bool = false
    ) -> ConversationMessage {
        if let (pinyin, english) = pinyinMap[chinese] {
            return ConversationMessage(
                role: .npc,
                chinese: chinese,
                pinyin: pinyin,
                english: english,
                isClosing: isClosing
            )
        }
        return ConversationMessage(
            role: .npc,
            chinese: chinese,
            pinyin: "—",
            english: "(AI response — translation pending)",
            isClosing: isClosing
        )
    }
}
