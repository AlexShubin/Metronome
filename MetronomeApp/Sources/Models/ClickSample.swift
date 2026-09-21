//
//  ClickSample.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 12.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import AVFoundation

enum ClickSample: String, Sendable, Equatable, CaseIterable, Identifiable, CustomStringConvertible {
    case classic
    case digital
    case logicStyle

    var id: String { rawValue }

    var description: String {
        switch self {
        case .classic: "Classic"
        case .digital: "Digital"
        case .logicStyle: "Logic Style"
        }
    }
}

extension ClickSample {
    var accentedFile: AVAudioFile {
        let name: String = switch self {
        case .classic: "Classic Accented"
        case .digital: "Digital Accented"
        case .logicStyle: "Logic Style Accented"
        }
        return try! AVAudioFile(forReading: Bundle.main.url(forResource: name, withExtension: "wav")!)
    }

    var regularFile: AVAudioFile {
        let name: String = switch self {
        case .classic: "Classic Regular"
        case .digital: "Digital Regular"
        case .logicStyle: "Logic Style Regular"
        }
        return try! AVAudioFile(forReading: Bundle.main.url(forResource: name, withExtension: "wav")!)
    }
}
