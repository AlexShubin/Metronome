//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation
import Observation
import MetronomeEngine

enum MetronomeViewModelAction {
    case tempoChanged(tempo: Int)
    case clickSampleChanged(clickSample: ClickSampleViewState)
    case playStopTapped
    case tick
}

@MainActor
protocol MetronomeViewModelType: Observable {
    var tempo: Int { get }
    var clickSample: ClickSampleViewState { get }
    var playButtonState: PlayButtonViewState { get }
    var beats: [Beat] { get }
    func accept(action: MetronomeViewModelAction) async
}

@MainActor @Observable
class MetronomeViewModel: MetronomeViewModelType {
    private(set) var tempo = 120
    private(set) var clickSample: ClickSampleViewState = .classic
    private(set) var playButtonState: PlayButtonViewState = .play
    private(set) var beats: [Beat] = .idle

    @ObservationIgnored private let metronome: MetronomeType
    @ObservationIgnored private var observationTask: Task<Void, Never>?

    init(metronome: MetronomeType) {
        self.metronome = metronome
        observationTask = Task { [weak self, metronome] in
            for await metronomeState in await metronome.metronomeStateStream {
                guard !Task.isCancelled else { break }
                self?.applyState(metronomeState)
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    func accept(action: MetronomeViewModelAction) async {
        switch action {
        case .tempoChanged(let tempo):
            await metronome.changeTempo(to: Double(tempo))
        case .clickSampleChanged(let clickSample):
            await metronome.changeClickSample(to: ClickSample(clickSample))
        case .playStopTapped:
            switch playButtonState {
            case .stop: await metronome.stop()
            case .play: await metronome.play()
            }
        case .tick:
            await metronome.tick()
        }
    }

    private func applyState(_ metronomeState: MetronomeState) {
        tempo = Int(metronomeState.tempo)
        clickSample = ClickSampleViewState(metronomeState.clickSample)
        playButtonState = metronomeState.isPlaying ? .stop : .play
        beats = .bar(highlighting: metronomeState.currentBeat)
    }
}

private extension ClickSampleViewState {
    init(_ clickSample: ClickSample) {
        switch clickSample {
        case .classic: self = .classic
        case .digital: self = .digital
        case .logicStyle: self = .logicStyle
        }
    }
}

private extension ClickSample {
    init(_ viewState: ClickSampleViewState) {
        switch viewState {
        case .classic: self = .classic
        case .digital: self = .digital
        case .logicStyle: self = .logicStyle
        }
    }
}
