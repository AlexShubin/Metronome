//
//  Metronome.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

public protocol MetronomeType: Actor {
    func play()
    func stop()
    func changeTempo(to bpm: Double)
    func changeClickSample(to clickSample: ClickSample)

    var metronomeStateStream: AsyncStream<MetronomeState> { get }

    /// Position of the playhead within the current bar, from 0 to 1.
    nonisolated var progressWithinBar: Double { get }
}

public struct MetronomeState: Sendable {
    public var tempo: Double
    public var isPlaying: Bool
    public var clickSample: ClickSample

    public init(
        tempo: Double,
        isPlaying: Bool,
        clickSample: ClickSample = .classic
    ) {
        self.tempo = tempo
        self.isPlaying = isPlaying
        self.clickSample = clickSample
    }
}

actor Metronome: MetronomeType {
    private let metronomeEngine: MetronomeEngineType

    let metronomeStateStream: AsyncStream<MetronomeState>
    private let metronomeStateContinuation: AsyncStream<MetronomeState>.Continuation

    private var metronomeState = MetronomeState(
        tempo: 120,
        isPlaying: false,
        clickSample: .classic
    ) {
        didSet {
            metronomeStateContinuation.yield(metronomeState)
        }
    }

    nonisolated var progressWithinBar: Double {
        metronomeEngine.progressWithinBar
    }

    init(metronomeEngine: MetronomeEngineType) {
        self.metronomeEngine = metronomeEngine

        (metronomeStateStream, metronomeStateContinuation) = AsyncStream<MetronomeState>.makeStream()

        metronomeStateContinuation.yield(metronomeState)
    }

    isolated deinit {
        metronomeStateContinuation.finish()
    }

    func play() {
        metronomeState.isPlaying = true
        startPlayback()
    }

    func stop() {
        metronomeState.isPlaying = false
        metronomeEngine.stop()
    }

    func changeTempo(to bpm: Double) {
        metronomeState.tempo = bpm
        if metronomeState.isPlaying {
            startPlayback()
        }
    }

    func changeClickSample(to clickSample: ClickSample) {
        metronomeState.clickSample = clickSample
        if metronomeState.isPlaying {
            startPlayback()
        }
    }

    private func startPlayback() {
        metronomeEngine.play(bpm: metronomeState.tempo, clickSample: metronomeState.clickSample)
    }
}
