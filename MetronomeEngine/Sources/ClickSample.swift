
//
//  ClickSample.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 12.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Foundation

public enum ClickSample {
    case classic
    case digital
    case logicStyle

    public var accentedFile: URL {
        switch self {
        case .classic:
            Bundle.module.url(forResource: "Classic Accented", withExtension: "wav")!
        case .digital:
            Bundle.module.url(forResource: "Digital Accented", withExtension: "wav")!
        case .logicStyle:
            Bundle.module.url(forResource: "Logic Style Accented", withExtension: "wav")!
        }
    }

    public var regularFile: URL {
        switch self {
        case .classic:
            Bundle.module.url(forResource: "Classic Regular", withExtension: "wav")!
        case .digital:
            Bundle.module.url(forResource: "Digital Regular", withExtension: "wav")!
        case .logicStyle:
            Bundle.module.url(forResource: "Logic Style Regular", withExtension: "wav")!
        }
    }
}
