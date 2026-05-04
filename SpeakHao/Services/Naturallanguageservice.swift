//
//  Naturallanguageservice.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//
import Foundation
import NaturalLanguage

struct LanguageAnalysisResult {
    let detectedLanguage: String?      // e.g. "zh-Hans", "en"
    let isChinese: Bool
    let tokens: [String]               // Tokenized words/characters
    let isRelevantToContext: Bool      // Whether response touches the expected topic
}

class NaturalLanguageService {

    private let languageRecognizer = NLLanguageRecognizer()

    // MARK: - Language Detection

    /// Detect the language of the transcribed user speech
    func detectLanguage(in text: String) -> String? {
        languageRecognizer.reset()
        languageRecognizer.processString(text)
        return languageRecognizer.dominantLanguage?.rawValue
    }

    // MARK: - Tokenization

    /// Tokenize Chinese or English text into words
    // ⚠️ FIX: NLLanguage tidak punya static member .chineseSimplified di SDK ini.
    //         Gunakan NLLanguage("zh-Hans") sebagai pengganti.
    func tokenize(_ text: String, language: NLLanguage = NLLanguage("zh-Hans")) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.setLanguage(language)
        tokenizer.string = text

        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append(String(text[range]))
            return true
        }
        return tokens
    }

    // MARK: - Full Analysis

    /// Analyze user's spoken response in context of the current NPC prompt
    /// expectedKeywords: words the NPC conversation expects (e.g. greetings, numbers)
    func analyze(userText: String, expectedKeywords: [String] = []) -> LanguageAnalysisResult {
        let detectedLang = detectLanguage(in: userText)
        let isChinese = detectedLang?.hasPrefix("zh") ?? false

        // ⚠️ FIX: Gunakan NLLanguage("zh-Hans") dan NLLanguage("en") sebagai pengganti
        //         .chineseSimplified dan .english yang tidak tersedia di SDK ini.
        let language: NLLanguage = isChinese ? NLLanguage("zh-Hans") : NLLanguage("en")
        let tokens = tokenize(userText, language: language)

        // Simple relevance check: does user response contain any expected keywords?
        let loweredText = userText.lowercased()
        let isRelevant: Bool
        if expectedKeywords.isEmpty {
            isRelevant = true // No constraint
        } else {
            isRelevant = expectedKeywords.contains(where: { loweredText.contains($0.lowercased()) })
        }

        return LanguageAnalysisResult(
            detectedLanguage: detectedLang,
            isChinese: isChinese,
            tokens: tokens,
            isRelevantToContext: isRelevant
        )
    }
}
