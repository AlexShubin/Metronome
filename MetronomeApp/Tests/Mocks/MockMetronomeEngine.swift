//
//  MockMetronomeEngine.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import MetronomeEngine

final class MockMetronomeEngine: MetronomeEngineType, @unchecked Sendable {

    enum Call: Equatable {
        case play(bpm: Double, clickSample: ClickSample)
        case stop
    }
    // Safety: only mutated from the Metronome actor's isolation in tests.
    var calls = [Call]()
    var stubbedBarLength: Double = 100
    var stubbedSampleTime: Double = 0

    func play(bpm: Double, clickSample: ClickSample) -> BarLength {
        calls.append(.play(bpm: bpm, clickSample: clickSample))
        return stubbedBarLength
    }

    func stop() {
        calls.append(.stop)
    }

    var sampleTime: Double {
        return stubbedSampleTime
    }
}
