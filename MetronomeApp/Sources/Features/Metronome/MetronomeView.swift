//
//  MetronomeView.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

struct MetronomeView: View {
    @State var viewModel: MetronomeViewModelType

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            TimelineView(.animation(paused: viewModel.state.playButtonState == .play)) { _ in
                HStack(spacing: 40) {
                    ForEach(viewModel.beats) { beat in
                        circle(beat)
                    }
                }
                .frame(height: 80)
            }

            HStack(spacing: 24) {
                DraggableTempoControl(
                    tempo: .init(
                        get: { viewModel.state.tempo },
                        set: { newTempo in Task { await viewModel.accept(action: .tempoChanged(tempo: newTempo)) } }
                    ),
                    range: 40...240
                )
                PlayButton(state: viewModel.state.playButtonState) {
                    Task { await viewModel.accept(action: .playStopTapped) }
                }
            }

            ClickSamplePicker(
                selection: Binding(
                    get: { viewModel.state.clickSample },
                    set: { newSample in
                        Task { await viewModel.accept(action: .clickSampleChanged(clickSample: newSample)) }
                    }
                )
            )
        }
        .padding()
        .frame(minWidth: 360)
    }

    @ViewBuilder
    private func circle(_ beat: Beat) -> some View {
        let size: CGFloat = beat.highlighted ? 35 : 25

        ZStack {
            Color.clear
                .frame(width: 40, height: 40)
            Circle()
                .fill(beat.highlighted ? .red : .blue)
                .frame(width: size, height: size)
                .animation(.linear(duration: 0.1), value: beat.highlighted)
        }
    }
}

// MARK: - View State

struct MetronomeViewState: Equatable {
    var tempo: Int
    var clickSample: ClickSampleViewState
    var playButtonState: PlayButtonViewState

    static let initial = MetronomeViewState(
        tempo: 120,
        clickSample: .classic,
        playButtonState: .play
    )
}

struct Beat: Identifiable, Equatable {
    static let countPerBar = 4
    static let idle = (0..<Self.countPerBar).map { Beat(id: $0, highlighted: false) }

    let id: Int
    let highlighted: Bool
}
