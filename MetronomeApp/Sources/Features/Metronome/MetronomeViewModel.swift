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

    var playButtonState: PlayButtonViewState {
        isPlaying ? .stop : .play
    }

    var beats: [Beat] {
        guard isPlaying else { return Beat.idle }
        let position = Int(engine.progressWithinBar * Double(Beat.countPerBar))
        let current = min(max(position, 0), Beat.countPerBar - 1)
        return (0..<Beat.countPerBar).map { Beat(id: $0, highlighted: $0 == current) }
    }

    private var isPlaying = false

    @ObservationIgnored private let engine: MetronomeEngineType

    init(engine: MetronomeEngineType) {
        self.engine = engine
    }

    func accept(action: MetronomeViewModelAction) async {
        switch action {
        case .tempoChanged(let tempo):
            self.tempo = tempo
            await restartIfPlaying()
        case .clickSampleChanged(let clickSample):
            self.clickSample = clickSample
            await restartIfPlaying()
        case .playStopTapped:
            isPlaying.toggle()
            if isPlaying {
                await startPlayback()
            } else {
                await engine.stop()
            }
        }
    }

    private func restartIfPlaying() async {
        guard isPlaying else { return }
        await startPlayback()
    }

    private func startPlayback() async {
        await engine.play(bpm: Double(tempo), clickSample: ClickSample(clickSample))
    }
}

struct Beat: Identifiable, Equatable {
    static let countPerBar = 4
    static let idle = (0..<Self.countPerBar).map { Beat(id: $0, highlighted: false) }

    let id: Int
    let highlighted: Bool
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
