//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation
import Observation

@MainActor
protocol MetronomeViewModelType: Observable {
    var tempo: Int { get }
    var clickSample: ClickSample { get }
    var playButtonState: PlayButtonState { get }
    var beats: [Beat] { get }

    func tempoChanged(tempo: Int)
    func clickSampleChanged(clickSample: ClickSample)
    func playStopTapped()
    func tick()
}

@MainActor @Observable
class MetronomeViewModel: MetronomeViewModelType {
    private(set) var tempo = 120
    private(set) var clickSample: ClickSample = .classic

    var playButtonState: PlayButtonState {
        isPlaying ? .stop : .play
    }

    var beats: [Beat] {
        .bar(highlighting: currentBeat)
    }

    private var isPlaying = false
    private var currentBeat: Int?

    @ObservationIgnored private let engine: MetronomeEngineType
    @ObservationIgnored private var barLength: BarLength = 0

    init(engine: MetronomeEngineType) {
        self.engine = engine
    }

    func tempoChanged(tempo: Int) {
        self.tempo = tempo
        restartPlaybackIfNeeded()
    }

    func clickSampleChanged(clickSample: ClickSample) {
        self.clickSample = clickSample
        restartPlaybackIfNeeded()
    }

    func playStopTapped() {
        if isPlaying {
            isPlaying = false
            currentBeat = nil
            engine.stop()
        } else {
            isPlaying = true
            restartPlaybackIfNeeded()
        }
    }

    func tick() {
        guard isPlaying, barLength > 0 else { return }
        let progress = engine.sampleTime.truncatingRemainder(dividingBy: barLength) / barLength
        let beat = Int(progress * Double(BeatsPerBar.value))
        guard beat != currentBeat else { return }
        currentBeat = beat
    }

    private func restartPlaybackIfNeeded() {
        if isPlaying {
            barLength = engine.play(bpm: Double(tempo), clickSample: clickSample)
        }
    }
}

enum PlayButtonState: Equatable {
    case play, stop
}

struct Beat: Identifiable, Equatable {
    let id: Int
    let highlighted: Bool
}

private extension [Beat] {
    static func bar(highlighting beat: Int?) -> [Beat] {
        (0..<BeatsPerBar.value).map { Beat(id: $0, highlighted: $0 == beat) }
    }
}
