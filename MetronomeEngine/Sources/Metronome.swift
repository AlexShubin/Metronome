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
}

public struct MetronomeState: Sendable {
    public var tempo: Double
    public var isPlaying: Bool
    public var progressWithinBar: Double
    public var clickSample: ClickSample

    public init(
        tempo: Double,
        isPlaying: Bool,
        progressWithinBar: Double,
        clickSample: ClickSample = .classic
    ) {
        self.tempo = tempo
        self.isPlaying = isPlaying
        self.progressWithinBar = progressWithinBar
        self.clickSample = clickSample
    }
}

actor Metronome: MetronomeType {
    private let metronomeEngine: MetronomeEngineType
    private let displayLink: DisplayLinkTickerType

    let metronomeStateStream: AsyncStream<MetronomeState>
    private let metronomeStateContinuation: AsyncStream<MetronomeState>.Continuation

    private var barLength: Double = 0

    private var metronomeState = MetronomeState(
        tempo: 120,
        isPlaying: false,
        progressWithinBar: 0,
        clickSample: .classic
    ) {
        didSet {
            metronomeStateContinuation.yield(metronomeState)
        }
    }

    init(metronomeEngine: MetronomeEngineType, displayLink: DisplayLinkTickerType) {
        self.metronomeEngine = metronomeEngine
        self.displayLink = displayLink

        (metronomeStateStream, metronomeStateContinuation) = AsyncStream<MetronomeState>.makeStream()

        let task = Task { [weak self] in
            await self?.startObservingTicker()
        }

        metronomeStateContinuation.onTermination = { _ in
            task.cancel()
        }
    }

    isolated deinit {
        metronomeStateContinuation.finish()
    }

    private func startObservingTicker() async {
        metronomeStateContinuation.yield(metronomeState)
        for await _ in displayLink.ticks {
            guard barLength > 0 else { continue }
            metronomeState.progressWithinBar = metronomeEngine.sampleTime
                .truncatingRemainder(dividingBy: barLength) / barLength
        }
    }

    func play() {
        metronomeState.isPlaying = true
        startPlayback()
    }

    func stop() {
        metronomeState.isPlaying = false
        metronomeEngine.stop()
        displayLink.pause()
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
        barLength = metronomeEngine.play(bpm: metronomeState.tempo, clickSample: metronomeState.clickSample)
        displayLink.resume()
    }
}
