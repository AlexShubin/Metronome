//
//  MetronomeEngineMock.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 21.09.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import MetronomeApp

final class MetronomeEngineMock: MetronomeEngineType {

    enum Calls: Equatable {
        case play(bpm: Double, clickSample: ClickSample)
        case stop
    }

    private(set) var calls: [Calls] = []

    var playResult: BarLength = 0
    func play(bpm: Double, clickSample: ClickSample) -> BarLength {
        calls.append(.play(bpm: bpm, clickSample: clickSample))
        return playResult
    }

    func stop() {
        calls.append(.stop)
    }

    var sampleTime: Double = 0
}
