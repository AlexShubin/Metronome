//
//  MetronomeViewModelTests.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 25.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
@testable import MetronomeApp

@Suite @MainActor
struct MetronomeViewModelTests {
    var engineMock: MetronomeEngineMock!
    var sut: MetronomeViewModelType!

    init() {
        engineMock = MetronomeEngineMock()
    }

    mutating func createSut() {
        sut = MetronomeViewModel(engine: engineMock)
    }

    // MARK: - Initial state

    @Test
    mutating func initialState() {
        createSut()

        #expect(sut.tempo == 120)
        #expect(sut.clickSample == .classic)
        #expect(sut.playButtonState == .play)
        #expect(sut.beats == [
            Beat(id: 0, highlighted: false),
            Beat(id: 1, highlighted: false),
            Beat(id: 2, highlighted: false),
            Beat(id: 3, highlighted: false),
        ])
    }

    // MARK: - Play and stop

    @Test
    mutating func playStopTapped_whenStopped_startsPlayback() {
        createSut()

        sut.playStopTapped()

        #expect(sut.playButtonState == .stop)
        #expect(engineMock.calls == [.play(bpm: 120, clickSample: .classic)])
    }

    @Test
    mutating func playStopTapped_whenPlaying_stopsEngine() {
        createSut()

        sut.playStopTapped()
        sut.playStopTapped()

        #expect(sut.playButtonState == .play)
        #expect(engineMock.calls == [.play(bpm: 120, clickSample: .classic), .stop])
    }

    @Test
    mutating func playStopTapped_whenPlaying_clearsHighlight() {
        engineMock.playResult = 100
        engineMock.sampleTime = 50
        createSut()
        sut.playStopTapped()
        sut.tick()

        sut.playStopTapped()

        #expect(sut.beats == [
            Beat(id: 0, highlighted: false),
            Beat(id: 1, highlighted: false),
            Beat(id: 2, highlighted: false),
            Beat(id: 3, highlighted: false),
        ])
    }

    // MARK: - Tempo

    @Test
    mutating func tempoChanged_updatesTempo() {
        createSut()

        sut.tempoChanged(tempo: 180)

        #expect(sut.tempo == 180)
    }

    @Test
    mutating func tempoChanged_whilePlaying_restartsPlayback() {
        createSut()
        sut.playStopTapped()

        sut.tempoChanged(tempo: 180)

        #expect(engineMock.calls == [
            .play(bpm: 120, clickSample: .classic),
            .play(bpm: 180, clickSample: .classic),
        ])
    }

    @Test
    mutating func tempoChanged_whileStopped_doesNotTouchEngine() {
        createSut()

        sut.tempoChanged(tempo: 180)

        #expect(engineMock.calls.isEmpty)
    }

    // MARK: - Click sample

    @Test
    mutating func clickSampleChanged_updatesClickSample() {
        createSut()

        sut.clickSampleChanged(clickSample: .digital)

        #expect(sut.clickSample == .digital)
    }

    @Test
    mutating func clickSampleChanged_whilePlaying_restartsPlayback() {
        createSut()
        sut.playStopTapped()

        sut.clickSampleChanged(clickSample: .digital)

        #expect(engineMock.calls == [
            .play(bpm: 120, clickSample: .classic),
            .play(bpm: 120, clickSample: .digital),
        ])
    }

    @Test
    mutating func clickSampleChanged_whileStopped_doesNotTouchEngine() {
        createSut()

        sut.clickSampleChanged(clickSample: .digital)

        #expect(engineMock.calls.isEmpty)
    }

    // MARK: - Tick

    @Test(arguments: [
        (0.0, 0),
        (24.0, 0),
        (25.0, 1),
        (50.0, 2),
        (75.0, 3),
        (99.0, 3),
        (150.0, 2),
        (200.0, 0),
    ])
    mutating func tick_highlightsBeatUnderPlayhead(sampleTime: Double, expectedBeat: Int) {
        engineMock.playResult = 100
        engineMock.sampleTime = sampleTime
        createSut()
        sut.playStopTapped()

        sut.tick()

        #expect(sut.beats == [
            Beat(id: 0, highlighted: expectedBeat == 0),
            Beat(id: 1, highlighted: expectedBeat == 1),
            Beat(id: 2, highlighted: expectedBeat == 2),
            Beat(id: 3, highlighted: expectedBeat == 3),
        ])
    }

    @Test
    mutating func tick_whileStopped_highlightsNothing() {
        engineMock.sampleTime = 50
        createSut()

        sut.tick()

        #expect(sut.beats == [
            Beat(id: 0, highlighted: false),
            Beat(id: 1, highlighted: false),
            Beat(id: 2, highlighted: false),
            Beat(id: 3, highlighted: false),
        ])
    }

    @Test
    mutating func tick_withoutBarLength_highlightsNothing() {
        engineMock.playResult = 0
        engineMock.sampleTime = 50
        createSut()
        sut.playStopTapped()

        sut.tick()

        #expect(sut.beats == [
            Beat(id: 0, highlighted: false),
            Beat(id: 1, highlighted: false),
            Beat(id: 2, highlighted: false),
            Beat(id: 3, highlighted: false),
        ])
    }

}
