//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation
import Observation

enum MetronomeViewModelAction {
    case tempoChanged(tempo: Int)
    case clickSampleChanged(clickSample: ClickSample)
    case playStopTapped
    case tick
}

@MainActor
protocol MetronomeViewModelType: Observable {
    var tempo: Int { get }
    var clickSample: ClickSample { get }
    var playButtonState: PlayButtonState { get }
    var beats: [Beat] { get }
    func accept(action: MetronomeViewModelAction) async
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

    func accept(action: MetronomeViewModelAction) async {
        switch action {
        case .tempoChanged(let tempo):
            self.tempo = tempo
            restartPlaybackIfNeeded()
        case .clickSampleChanged(let clickSample):
            self.clickSample = clickSample
            restartPlaybackIfNeeded()
        case .playStopTapped:
            if isPlaying {
                stopPlayback()
            } else {
                startPlayback()
            }
        case .tick:
            updateCurrentBeat()
        }
    }

    private func startPlayback() {
        isPlaying = true
        schedulePlayback()
    }

    private func stopPlayback() {
        isPlaying = false
        currentBeat = nil
        engine.stop()
    }

    private func restartPlaybackIfNeeded() {
        guard isPlaying else { return }
        schedulePlayback()
    }

    private func schedulePlayback() {
        barLength = engine.play(bpm: Double(tempo), clickSample: clickSample)
    }

    private func updateCurrentBeat() {
        guard isPlaying, barLength > 0 else { return }
        let progress = engine.sampleTime.truncatingRemainder(dividingBy: barLength) / barLength
        let beat = min(max(Int(progress * Double(BeatsPerBar.value)), 0), BeatsPerBar.value - 1)
        guard beat != currentBeat else { return }
        currentBeat = beat
    }
}

enum PlayButtonState: Equatable {
    case play
    case stop
}
