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

    /// Samples the playhead and republishes the state if the bar has moved on to another beat.
    func tick()

    var metronomeStateStream: AsyncStream<MetronomeState> { get }
}

public struct MetronomeState: Sendable, Equatable {
    public static let beatsPerBar = 4

    public var tempo: Double
    public var isPlaying: Bool
    /// Index of the beat the playhead is on, or `nil` while stopped.
    public var currentBeat: Int?
    public var clickSample: ClickSample

    public init(
        tempo: Double,
        isPlaying: Bool,
        currentBeat: Int? = nil,
        clickSample: ClickSample = .classic
    ) {
        self.tempo = tempo
        self.isPlaying = isPlaying
        self.currentBeat = currentBeat
        self.clickSample = clickSample
    }
}

actor Metronome: MetronomeType {
    private let metronomeEngine: MetronomeEngineType

    let metronomeStateStream: AsyncStream<MetronomeState>
    private let metronomeStateContinuation: AsyncStream<MetronomeState>.Continuation

    private var barLength: BarLength = 0

    private var metronomeState = MetronomeState(
        tempo: 120,
        isPlaying: false,
        currentBeat: nil,
        clickSample: .classic
    ) {
        didSet {
            guard metronomeState != oldValue else { return }
            metronomeStateContinuation.yield(metronomeState)
        }
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
        metronomeState.currentBeat = nil
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

    func tick() {
        guard metronomeState.isPlaying, barLength > 0 else { return }
        let progress = metronomeEngine.sampleTime.truncatingRemainder(dividingBy: barLength) / barLength
        let beat = Int(progress * Double(MetronomeState.beatsPerBar))
        metronomeState.currentBeat = min(max(beat, 0), MetronomeState.beatsPerBar - 1)
    }

    private func startPlayback() {
        barLength = metronomeEngine.play(bpm: metronomeState.tempo, clickSample: metronomeState.clickSample)
    }
}
