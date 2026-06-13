//
//  MiloMood+Dialogue.swift
//  Milo
//
//  Created by Hendra Irawan on 12/06/26.
//

extension MiloMood {
    var dialogue: String {
        switch self {
        case .idle:
            "I'm here. Say what you need."
        case .typing:
            "I am writing it down."
        case .happy:
            "Nice. That felt good."
        case .confused:
            "I need one more clue."
        case .sleepy:
            "Low power, still listening."
        case .reminder:
            "I can keep that on your radar."
        case .focus:
            "Focus mode on. I will stay quiet."
        }
    }
}
