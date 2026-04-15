//
//  MetronomeViewModelTests.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 25.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
import Observation
import MetronomeEngine
import MetronomeEngineTestSupport
@testable import MetronomeApp

@Suite @MainActor
struct MetronomeViewModelTests {
    let mockMetronome: MockMetronome
    let sut: MetronomeViewModelType

    init() {
        mockMetronome = .init()
        sut = MetronomeViewModel(metronome: mockMetronome)
    }

    // MARK: - Helpers

    private func sendState(_ state: MetronomeState) async {
        await withCheckedContinuation { continuation in
            withObservationTracking {
                _ = sut.state
            } onChange: {
                continuation.resume()
            }
            mockMetronome.sendState(state)
        }
    }

    // MARK: - Tests

    @Test func initialState() {
        #expect(sut.state == .initial)
    }

    @Test func stateUpdates_onMetronomeStateChange() async {
        await sendState(
            MetronomeState(tempo: 140, isPlaying: true, progressWithinBar: 0.3)
        )

        #expect(sut.state.tempo == 140)
        #expect(sut.state.playButtonState == .stop)
        #expect(sut.state.beats[0].highlighted == false)
        #expect(sut.state.beats[1].highlighted == true)
        #expect(sut.state.beats[2].highlighted == false)
        #expect(sut.state.beats[3].highlighted == false)
    }

    @Test func playStopTapped_whenStopped_callsPlay() async {
        await sut.accept(action: .playStopTapped)

        #expect(await mockMetronome.calls == [.play])
    }

    @Test func playStopTapped_whenPlaying_callsStop() async {
        await sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0)
        )

        await sut.accept(action: .playStopTapped)

        #expect(await mockMetronome.calls == [.stop])
    }

    @Test func tempoChanged_callsChangeTempo() async {
        await sut.accept(action: .tempoChanged(tempo: 180))

        #expect(await mockMetronome.calls == [.changeTempo(bpm: 180)])
    }
    
    @Test func clickSampleChanged_callsChangeClickSample() async {
        await sut.accept(action: .clickSampleChanged(clickSample: .digital))

        #expect(await mockMetronome.calls == [.changeClickSample(clickSample: .digital)])
    }

    @Test func settingsTapped_setsDestination() async {
        await sut.accept(action: .settingsTapped)

        #expect(sut.destination == .settings)
    }

    @Test func beatHighlighting_firstQuarter() async {
        await sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0.1)
        )

        #expect(sut.state.beats[0].highlighted == true)
        #expect(sut.state.beats[1].highlighted == false)
    }

    @Test func beatHighlighting_thirdQuarter() async {
        await sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0.6)
        )

        #expect(sut.state.beats[2].highlighted == true)
    }

    @Test func beats_whenNotPlaying_allUnhighlighted() async {
        await sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0)
        )
        await sendState(
            MetronomeState(tempo: 120, isPlaying: false, progressWithinBar: 0.5)
        )

        #expect(sut.state.beats == MetronomeViewState.initial.beats)
    }
}
