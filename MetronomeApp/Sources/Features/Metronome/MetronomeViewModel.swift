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
}

@MainActor
protocol MetronomeViewModelType: Observable {
    var state: MetronomeViewState { get }
    var beats: [Beat] { get }
    func accept(action: MetronomeViewModelAction) async
}

@MainActor @Observable
class MetronomeViewModel: MetronomeViewModelType {
    private(set) var state: MetronomeViewState = .initial

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

    var beats: [Beat] {
        guard state.playButtonState == .stop else { return Beat.idle }
        let position = Int(metronome.progressWithinBar * Double(Beat.countPerBar))
        let current = min(max(position, 0), Beat.countPerBar - 1)
        return (0..<Beat.countPerBar).map { Beat(id: $0, highlighted: $0 == current) }
    }

    private func applyState(_ metronomeState: MetronomeState) {
        state = MetronomeViewState(metronomeState)
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
        }
    }
}

private extension MetronomeViewState {
    init(_ metronomeState: MetronomeState) {
        tempo = Int(metronomeState.tempo)
        clickSample = ClickSampleViewState(metronomeState.clickSample)
        playButtonState = metronomeState.isPlaying ? .stop : .play
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
