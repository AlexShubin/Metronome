//
//  Dependencies.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 13.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

public struct Dependencies: Sendable {
    public let engine: MetronomeEngineType

    public static let live = Dependencies(engine: MetronomeEngine())
}
