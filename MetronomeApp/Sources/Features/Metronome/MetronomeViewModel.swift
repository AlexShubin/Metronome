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
    case settingsTapped
}

enum MetronomeDestination: Identifiable, Equatable {
    case settings

    var id: String {
        switch self {
        case .settings: "settings"
        }
    }
}

@MainActor
protocol MetronomeViewModelType: Observable {
    var state: MetronomeViewState { get }
    var destination: MetronomeDestination? { get set }
    func accept(action: MetronomeViewModelAction) async
}

@MainActor @Observable
class MetronomeViewModel: MetronomeViewModelType {
    private(set) var state: MetronomeViewState = .initial

    var destination: MetronomeDestination?

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

    private func applyState(_ metronomeState: MetronomeState) {
        state = MetronomeViewState(metronomeState)
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
            switch state.playButtonState {
            case .stop: await metronome.stop()
            case .play: await metronome.play()
            }
        case .settingsTapped:
            destination = .settings
        }
    }
}

private extension MetronomeViewState {
    init(_ metronomeState: MetronomeState) {
        tempo = Int(metronomeState.tempo)
        clickSample = ClickSampleViewState(metronomeState.clickSample)
        playButtonState = metronomeState.isPlaying ? .stop : .play
        beats = if metronomeState.isPlaying {
            [
                .init(id: 0, highlighted: (0...0.25).contains(metronomeState.progressWithinBar)),
                .init(id: 1, highlighted: (0.25...0.5).contains(metronomeState.progressWithinBar)),
                .init(id: 2, highlighted: (0.5...0.75).contains(metronomeState.progressWithinBar)),
                .init(id: 3, highlighted: (0.75...1).contains(metronomeState.progressWithinBar)),
            ]
        } else {
            MetronomeViewState.initial.beats
        }
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
