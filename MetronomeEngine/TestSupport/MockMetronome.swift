//
//  MockMetronome.swift
//  MetronomeEngineTestSupport
//
//  Created by Alex Shubin on 25.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import MetronomeEngine

public actor MockMetronome: MetronomeType {

    public enum Call: Equatable, Sendable {
        case play
        case stop
        case changeTempo(bpm: Double)
        case changeClickSample(clickSample: ClickSample)
    }

    public private(set) var calls = [Call]()

    public let metronomeStateStream: AsyncStream<MetronomeState>
    private let metronomeStateContinuation: AsyncStream<MetronomeState>.Continuation

    public init() {
        (metronomeStateStream, metronomeStateContinuation) = AsyncStream<MetronomeState>.makeStream()
    }

    public func play() {
        calls.append(.play)
    }

    public func stop() {
        calls.append(.stop)
    }

    public func changeTempo(to bpm: Double) {
        calls.append(.changeTempo(bpm: bpm))
    }

    public func changeClickSample(to clickSample: ClickSample) {
        calls.append(.changeClickSample(clickSample: clickSample))
    }

    public nonisolated func sendState(_ state: MetronomeState) {
        metronomeStateContinuation.yield(state)
    }
}
