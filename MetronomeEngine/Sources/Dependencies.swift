//
//  Dependencies.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 13.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

public struct Dependencies: Sendable {
    public static let live = Dependencies()

    public func makeMetronome() -> MetronomeType {
        Metronome(metronomeEngine: MetronomeEngine())
    }
}
