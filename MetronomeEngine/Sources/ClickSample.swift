
//
//  ClickSample.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 12.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

public enum ClickSample: Sendable, Equatable {
    case classic
    case digital
    case logicStyle
}

import AVFoundation

extension ClickSample {
    var accentedFile: AVAudioFile {
        let name: String = switch self {
        case .classic: "Classic Accented"
        case .digital: "Digital Accented"
        case .logicStyle: "Logic Style Accented"
        }
        return try! AVAudioFile(forReading: Bundle.module.url(forResource: name, withExtension: "wav")!)
    }

    var regularFile: AVAudioFile {
        let name: String = switch self {
        case .classic: "Classic Regular"
        case .digital: "Digital Regular"
        case .logicStyle: "Logic Style Regular"
        }
        return try! AVAudioFile(forReading: Bundle.module.url(forResource: name, withExtension: "wav")!)
    }
}
