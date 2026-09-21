//
//  MetronomeEngine.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation

protocol MetronomeEngineType {
    /// Starts the metronome.
    /// - Parameters:
    ///   - bpm: Tempo. Beats per minute.
    ///   - clickSample: The click sample to use.
    /// - Returns: Returns the bar length in frames, so later on we can understand the position of the player within the bar.
    func play(bpm: Double, clickSample: ClickSample) -> BarLength

    func stop()

    /// Accumulative time of the playhead.
    /// Note that if it played two bars in total, it will return the accumulative time of two bars.
    var sampleTime: Double { get }
}

typealias BarLength = Double

class MetronomeEngine: MetronomeEngineType {
    private let audioPlayerNode: AVAudioPlayerNode
    private let audioEngine: AVAudioEngine

    init() {
        audioPlayerNode = AVAudioPlayerNode()

        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)

        audioEngine.connect(audioPlayerNode,
                            to: audioEngine.mainMixerNode,
                            format: .standard)
        try! audioEngine.start()
    }

    func stop() {
        audioPlayerNode.stop()
    }

    func play(bpm: Double, clickSample: ClickSample) -> BarLength {
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

        return Double(buffer.frameLength)
    }

    var sampleTime: Double {
        guard let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            return 0
        }

        return Double(playerTime.sampleTime)
    }

    private func generateBuffer(bpm: Double, clickSample: ClickSample) -> AVAudioPCMBuffer {
        let beatLength = AVAudioFrameCount(AVAudioFormat.standard.sampleRate * 60 / bpm)
        let barLength = AVAudioFrameCount(BeatsPerBar.value) * beatLength

        let accentedClickSamples = readSamples(from: clickSample.accentedFile, beatLength: beatLength)
        let mainClickSamples = readSamples(from: clickSample.regularFile, beatLength: beatLength)

        var barSamples = accentedClickSamples
        for _ in 1..<BeatsPerBar.value {
            barSamples.append(contentsOf: mainClickSamples)
        }

        let bufferBar = AVAudioPCMBuffer(pcmFormat: .standard, frameCapacity: barLength)!
        bufferBar.frameLength = barLength
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
