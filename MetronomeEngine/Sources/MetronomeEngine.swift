//
//  MetronomeEngine.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation
import Synchronization

public protocol MetronomeEngineType: Sendable {
    /// Starts the metronome, replacing whatever is currently looping.
    /// - Parameters:
    ///   - bpm: Tempo. Beats per minute.
    ///   - clickSample: The click sample to use.
    func play(bpm: Double, clickSample: ClickSample) async

    func stop() async

    /// Position of the playhead within the current bar, from 0 to 1.
    /// Safe to read from any isolation, so the UI can sample it every frame.
    nonisolated var progressWithinBar: Double { get }
}

actor MetronomeEngine: MetronomeEngineType {
    private let audioEngine: AVAudioEngine
    private let audioPlayerNode: AVAudioPlayerNode
    private let barLength = Mutex<Double>(0)

    init() {
        audioPlayerNode = AVAudioPlayerNode()

        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)

        audioEngine.connect(audioPlayerNode,
                            to: audioEngine.mainMixerNode,
                            format: .standard)
        try! audioEngine.start()
    }

    nonisolated var progressWithinBar: Double {
        let length = barLength.withLock { $0 }
        guard length > 0 else { return 0 }
        return sampleTime.truncatingRemainder(dividingBy: length) / length
    }

    func stop() {
        audioPlayerNode.stop()
    }

    func play(bpm: Double, clickSample: ClickSample) {
        let buffer = generateBuffer(bpm: bpm, clickSample: clickSample)

        if audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
        }

        audioPlayerNode.play()

        audioPlayerNode.scheduleBuffer(
            buffer,
            at: nil,
            options: [.interruptsAtLoop, .loops]
        )

        barLength.withLock { $0 = Double(buffer.frameLength) }
    }

    /// Accumulative time of the playhead.
    /// Note that if it played two bars in total, it will return the accumulative time of two bars.
    private nonisolated var sampleTime: Double {
        guard let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            return 0
        }

        return Double(playerTime.sampleTime)
    }

    private func generateBuffer(bpm: Double, clickSample: ClickSample) -> AVAudioPCMBuffer {
        let beatLength = AVAudioFrameCount(AVAudioFormat.standard.sampleRate * 60 / bpm)

        let accentedClickSamples = readSamples(from: clickSample.accentedFile, beatLength: beatLength)
        let mainClickSamples = readSamples(from: clickSample.regularFile, beatLength: beatLength)

        var barSamples = accentedClickSamples
        for _ in 1...3 {
            barSamples.append(contentsOf: mainClickSamples)
        }

        let bufferBar = AVAudioPCMBuffer(pcmFormat: .standard, frameCapacity: 4 * beatLength)!
        bufferBar.frameLength = 4 * beatLength
        bufferBar.floatChannelData!.pointee.update(from: barSamples,
                                                   count: Int(bufferBar.frameLength))
        return bufferBar
    }

    private func readSamples(
        from file: AVAudioFile,
        beatLength: AVAudioFrameCount
    ) -> [Float] {
        let buffer = AVAudioPCMBuffer(pcmFormat: .standard, frameCapacity: beatLength)!
        try! file.read(into: buffer)
        buffer.frameLength = beatLength
        return Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(beatLength)))
    }
}

private extension AVAudioFormat {
    static let standard = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!
}
