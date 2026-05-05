//
//  Scenariomenubridge.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/6/26.
//

import SwiftUI

// MARK: - Chapter Card Model

struct ChapterCard: Identifiable {
    let id: Int
    let scenario: NPCScenario
    let characterImage: String
    let isLocked: Bool

    var title:   String { scenario.title }
    var preview: String { scenario.description }   // baca langsung dari NPCScenario.description
}

// MARK: - ScenarioRegistry Extension

extension ScenarioRegistry {
    static var chapterCards: [ChapterCard] {
        all.enumerated().map { index, scenario in
            ChapterCard(
                id: index + 1,
                scenario: scenario,
                characterImage: "character_idle",
                isLocked: index > 0
            )
        }
    }
}

// MARK: - MainMenuSwipe2

struct MainMenuSwipe2: View {

    var body: some View {
        ZStack(alignment: .bottom) {

            Image("Background")
                .resizable()
                .scaleEffect(1.7)
                .offset(x: -140, y: -300)
                .ignoresSafeArea()

            TabView {
                ForEach(ScenarioRegistry.chapterCards) { card in
                    cardPage(card: card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func cardPage(card: ChapterCard) -> some View {
        if card.isLocked {
            ZStack {
                MainMenuView(
                    chapterNumber:  card.id,
                    chapterTitle:   card.title,
                    chapterPreview: card.preview,
                    characterImage: card.characterImage
                )
                PopUpLocked()
            }
        } else {
            ZStack {
                MainMenuView(
                    chapterNumber:  card.id,
                    chapterTitle:   card.title,
                    chapterPreview: card.preview,
                    characterImage: card.characterImage
                )
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: ConversationView(scenario: card.scenario)) {
                            Color.clear.frame(width: 220, height: 48)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 90)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MainMenuSwipe2()
    }
}
