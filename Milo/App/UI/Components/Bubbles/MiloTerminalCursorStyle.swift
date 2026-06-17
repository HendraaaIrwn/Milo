//
//  MiloTerminalCursorStyle.swift
//  Milo
//

import Foundation

enum MiloTerminalCursorStyle: Equatable {
    case underline
    case block

    var symbol: String {
        switch self {
        case .underline: return "_"
        case .block:     return "\u{2588}"
        }
    }
}
