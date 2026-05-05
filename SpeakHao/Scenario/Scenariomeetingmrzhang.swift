//
//  Scenariomeetingmrzhang.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/5/26.
//
import Foundation

struct ClientMeetingMrZhangScenario: ScenarioProvider {

    // MARK: - Scenario Definition

    static var scenario: NPCScenario {
        NPCScenario(
            id: "client_meeting_mr_zhang",
            title: "Online Meeting: Mr. Zhang",
            description: "You play a developer building an internal management system for a client based in Shanghai. Mr. Zhang (张先生) has called to check on your progress, ask about any blockers, and find out when the system will be ready. He's polite but firm he wants it done in 2 days. Practice answering professional questions in Mandarin and negotiate the deadline with confidence.",
            baseSystemPrompt: """
            You are Mr. Zhang (张先生), a professional client representative from Shanghai.
            You're in a meeting with a developer building an internal management system.

            CHARACTER TRAITS:
            - Professional, direct, focused on results
            - Want system in 2 days (not 3 or more)
            - Push politely but firmly when needed
            - React authentically to emotions
            - Kind but businesslike

            LANGUAGE RULES (STRICT):
            - Reply ONLY in Simplified Chinese. NO pinyin, NO English.
            - 1-2 sentences max. Usually just 1.
            - Simple words. Beginner-friendly.
            - ONE focused question per turn maximum.
            - NEVER repeat the exact same question consecutively.

            EMOTIONAL RESPONSES (Be real):
            - Rude/curse words → 1 line brief disapproval, then redirect
            - Off-topic → Acknowledge kindly once, then naturally steer back
            - Positive/cooperative → Return warmth briefly
            - Confused/vague → Ask clarification or move forward if reasonable

            MEETING GOAL - Gather 3 things naturally:
              ① Progress status of system
              ② Any problems/blockers they're facing
              ③ Timeline to complete (push for 2 days)
            After confirming follow-up → Close meeting warmly.

            You decide what's on-topic or off-topic. Be smart.
            Use context from earlier parts of the conversation.
            Move the meeting forward naturally.
            """,
            stages: [
                // Stage 0 — Opening/Greeting
                ConversationStage(
                    stagePrompt: """
                    Opening: Greet the developer warmly. Thank them for their time.
                    Wait for them to greet back or acknowledge.
                    Be warm but professional.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "你好，最近怎么样？谢谢你今天抽时间参加会议。",
                        pinyin: "Nǐ hǎo, zuìjìn zěnme yàng? Xièxie nǐ jīntiān chōu shíjiān cānjiā huìyì.",
                        english: "Hello, how have you been? Thank you for taking the time to join today's meeting."
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 1 — Introduce Topic / Ask about Progress
                ConversationStage(
                    stagePrompt: """
                    Intro: Briefly mention you want to discuss the system progress and timeline.
                    Ask: How is the system coming along? What's the current status?
                    Ask ONE question. Be direct but warm.
                    
                    Foundation Model will decide if response is relevant enough to move on.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "好，今天想了解一下系统的进展。现在做到哪一步了？",
                        pinyin: "Hǎo, jīntiān xiǎng liǎojiě yíxià xìtǒng de jìnzhǎn. Xiànzài zuò dào nǎ yì bù le?",
                        english: "Good, I'd like to understand how the system is progressing. Where are we at now?"
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 2 — Follow-up on Progress (if vague)
                ConversationStage(
                    stagePrompt: """
                    If their first answer was vague or unclear, clarify.
                    Ask about percentage done, or specific modules.
                    But if they gave a clear answer (60%, backend done, etc) → move to problems stage.
                    
                    Foundation Model: Use judgment. Move on if answer was clear enough.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "能具体说一下吗？比如百分比或者哪些部分已经完成了？",
                        pinyin: "Néng jùtǐ shuō yíxià ma? Bǐrú bǎifēnbǐ huòzhě nǎxiē bùfen yǐjīng wánchéng le?",
                        english: "Can you be more specific? Like what percentage is done, or which parts are finished?"
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 3 — Ask about Problems/Blockers
                ConversationStage(
                    stagePrompt: """
                    Now ask if there are any problems, issues, bugs, or blockers.
                    Be open-ended. They might say no problems, or list some.
                    Accept either answer.
                    
                    Foundation Model: Acknowledge whatever they say, then move to timeline.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "过程中有没有遇到什么困难或问题？",
                        pinyin: "Guòchéng zhōng yǒu méiyǒu yùdào shénme kùnnan huò wèntí?",
                        english: "Have you run into any difficulties or problems along the way?"
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 4 — Acknowledge Problems (if any) / Move to Timeline
                ConversationStage(
                    stagePrompt: """
                    If they mentioned problems → acknowledge them briefly.
                    If they said no problems → acknowledge that's good.
                    Then ask: How long until it's done?
                    
                    Aim for direct answer about timeline (days/weeks/etc).
                    Foundation Model: Recognize timeline info and move on.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "明白。那大概什么时候能完成？",
                        pinyin: "Míngbai. Nà dàgài shénme shíhou néng wánchéng?",
                        english: "I see. When do you think it'll be done?"
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 5 — Clarify Timeline (if needed)
                ConversationStage(
                    stagePrompt: """
                    If they said "几天" (some days) → clarify how many.
                    If they said "3天" or exact number → move to pushing for 2 days.
                    Be direct: "是3天吗？能不能2天完成？"
                    
                    Foundation Model: Recognize the specific timeline, react appropriately.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "具体是多少天？",
                        pinyin: "Jùtǐ shì duōshao tiān?",
                        english: "Specifically, how many days?"
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 6 — Push for 2 Days
                ConversationStage(
                    stagePrompt: """
                    They likely said 3+ days.
                    Confirm: "三天？" Then push: "有可能2天完成吗？"
                    Be firm but polite. This is your real ask.
                    
                    Foundation Model: Respond to their answer (yes, no, need to check team, etc).
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "三天？有可能两天完成吗？我们确实很赶时间。",
                        pinyin: "Sān tiān? Yǒu kěnéng liǎng tiān wánchéng ma? Wǒmen quèshí hěn gǎn shíjiān.",
                        english: "Three days? Is it possible to do it in two? We're really pressed for time."
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 7 — Handle Their Response (will discuss team, etc)
                ConversationStage(
                    stagePrompt: """
                    They'll likely say "I need to check with my team" or "We'll try".
                    Acknowledge that. Express that you're available to support/help.
                    Ask them to confirm tomorrow or next day.
                    
                    Foundation Model: Accept their commitment, then move to closing.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "好的，你和团队商量一下。明天给我们消息怎么样？",
                        pinyin: "Hǎo de, nǐ hé tuánduì shāngliang yíxià. Míngtiān gěi wǒmen xiāoxi zěnmeyàng?",
                        english: "Okay, discuss it with your team. Can you give us an update tomorrow?"
                    ),
                    transitionKeywords: [],
                    isTerminal: false,
                    closingMessage: nil
                ),

                // Stage 8 — Confirm & Close (Terminal)
                ConversationStage(
                    stagePrompt: """
                    They confirmed they'll follow up.
                    Say goodbye warmly. Thank them. Say meeting went well.
                    This is the LAST message. Don't ask more questions.
                    Set isConversationComplete = true after this.
                    """,
                    openingMessage: ConversationMessage(
                        role: .npc,
                        chinese: "谢谢，那就这样。希望能尽快收到好消息。",
                        pinyin: "Xièxie, nà jiù zhèyàng. Xīwàng néng jìnkuài shōudào hǎo xiāoxi.",
                        english: "Thank you, let's go with that. Hoping to hear good news soon.",
                        isClosing: true
                    ),
                    transitionKeywords: [],
                    isTerminal: true,
                    closingMessage: nil
                )
            ]
        )
    }

    // MARK: - Pinyin Map

    static var pinyinMap: [String: (String, String)] {
        [
            "你好，最近怎么样？谢谢你今天抽时间参加会议。":
                (
                    "Nǐ hǎo, zuìjìn zěnme yàng? Xièxie nǐ jīntiān chōu shíjiān cānjiā huìyì.",
                    "Hello, how have you been? Thank you for taking the time to join today's meeting."
                ),
            "好，今天想了解一下系统的进展。现在做到哪一步了？":
                (
                    "Hǎo, jīntiān xiǎng liǎojiě yíxià xìtǒng de jìnzhǎn. Xiànzài zuò dào nǎ yì bù le?",
                    "Good, I'd like to understand how the system is progressing. Where are we at now?"
                ),
            "能具体说一下吗？比如百分比或者哪些部分已经完成了？":
                (
                    "Néng jùtǐ shuō yíxià ma? Bǐrú bǎifēnbǐ huòzhě nǎxiē bùfen yǐjīng wánchéng le?",
                    "Can you be more specific? Like what percentage is done, or which parts are finished?"
                ),
            "过程中有没有遇到什么困难或问题？":
                (
                    "Guòchéng zhōng yǒu méiyǒu yùdào shénme kùnnan huò wèntí?",
                    "Have you run into any difficulties or problems along the way?"
                ),
            "明白。那大概什么时候能完成？":
                (
                    "Míngbai. Nà dàgài shénme shíhou néng wánchéng?",
                    "I see. When do you think it'll be done?"
                ),
            "具体是多少天？":
                (
                    "Jùtǐ shì duōshao tiān?",
                    "Specifically, how many days?"
                ),
            "三天？有可能两天完成吗？我们确实很赶时间。":
                (
                    "Sān tiān? Yǒu kěnéng liǎng tiān wánchéng ma? Wǒmen quèshí hěn gǎn shíjiān.",
                    "Three days? Is it possible to do it in two? We're really pressed for time."
                ),
            "好的，你和团队商量一下。明天给我们消息怎么样？":
                (
                    "Hǎo de, nǐ hé tuánduì shāngliang yíxià. Míngtiān gěi wǒmen xiāoxi zěnmeyàng?",
                    "Okay, discuss it with your team. Can you give us an update tomorrow?"
                ),
            "谢谢，那就这样。希望能尽快收到好消息。":
                (
                    "Xièxie, nà jiù zhèyàng. Xīwàng néng jìnkuài shōudào hǎo xiāoxi.",
                    "Thank you, let's go with that. Hoping to hear good news soon."
                ),
        ]
    }

    // MARK: - Fallback Responses

    /// Rule-based fallback jika Foundation Models tidak tersedia.
    static func fallbackResponse(stageIndex: Int, userText: String) -> ConversationMessage {
        switch stageIndex {
        case 0:
            return makeNPCMessage(chinese: "好，今天想了解一下系统的进展。现在做到哪一步了？")
        case 1:
            return makeNPCMessage(chinese: "能具体说一下吗？比如百分比或者哪些部分已经完成了？")
        case 2:
            return makeNPCMessage(chinese: "过程中有没有遇到什么困难或问题？")
        case 3:
            return makeNPCMessage(chinese: "明白。那大概什么时候能完成？")
        case 4:
            return makeNPCMessage(chinese: "具体是多少天？")
        case 5:
            return makeNPCMessage(chinese: "三天？有可能两天完成吗？我们确实很赶时间。")
        case 6:
            return makeNPCMessage(chinese: "好的，你和团队商量一下。明天给我们消息怎么样？")
        case 7:
            return makeNPCMessage(
                chinese: "谢谢，那就这样。希望能尽快收到好消息。",
                isClosing: true
            )
        default:
            return makeNPCMessage(chinese: "谢谢。再见！", isClosing: true)
        }
    }
}
