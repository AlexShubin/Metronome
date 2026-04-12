//
//  MetronomeTests.swift
//  MetronomeEngineTests
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
@testable import MetronomeEngine

@Suite
struct MetronomeTests {
    let mockEngine: MockMetronomeEngine
    let mockDisplayLink: MockDisplayLinkTicker

    let sut: MetronomeType

    init() {
        mockEngine = .init()
        mockDisplayLink = .init()

        sut = Metronome(metronomeEngine: mockEngine,
                        displayLink: mockDisplayLink)
    }

    @Test func initialState() async {
        let state = await sut.metronomeStateStream.next()

        #expect(state?.tempo == 120)
        #expect(state?.isPlaying == false)
        #expect(state?.progressWithinBar == 0)
    }

    @Test func play_setsIsPlayingAndStartsEngine() async {
        await sut.play()
        let state = await sut.metronomeStateStream.dropFirst().next()

        #expect(state?.isPlaying == true)
        #expect(mockEngine.calls == [
            .play(bpm: 120, clickSample: .classic)
        ])
        #expect(mockDisplayLink.calls == [
            .resume
        ])
    }

    @Test func stop_setsIsNotPlayingAndStopsEngine() async {
        await sut.play()
        await sut.stop()
        let state = await sut.metronomeStateStream.dropFirst(2).next()

        #expect(state?.isPlaying == false)
        #expect(mockEngine.calls == [
            .play(bpm: 120, clickSample: .classic), .stop
        ])
        #expect(mockDisplayLink.calls == [
            .resume, .pause
        ])
    }

    @Test func changeTempo_updatesTempoInState() async {
        await sut.changeTempo(to: 180)
        let state = await sut.metronomeStateStream.dropFirst().next()

        #expect(state?.tempo == 180)
    }

    @Test func changeTempo_whilePlaying_restartsEngine() async {
        await sut.play()

        await sut.changeTempo(to: 180)

        #expect(mockEngine.calls == [
            .play(bpm: 120, clickSample: .classic), .play(bpm: 180, clickSample: .classic)
        ])
    }

    @Test func changeTempo_whileStopped_doesNotRestartEngine() async {
        await sut.changeTempo(to: 180)

        #expect(mockEngine.calls == [])
    }

    @Test func stateStream_emitsOnPlay() async {
        await sut.play()
        let state = await sut.metronomeStateStream.dropFirst().next()

        #expect(state?.isPlaying == true)
    }

    @Test func progressUpdates_onTick() async {
        mockEngine.stubbedSampleTime = 50
        mockEngine.stubbedBarLength = 100

        await sut.play()
        mockDisplayLink.sendTick()
        let state = await sut.metronomeStateStream.dropFirst(2).next()

        #expect(state?.progressWithinBar == 0.5)
    }
}
