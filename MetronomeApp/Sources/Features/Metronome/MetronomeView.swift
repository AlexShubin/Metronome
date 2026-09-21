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
            TimelineView(.animation(paused: viewModel.playButtonState == .play)) { context in
                HStack(spacing: 40) {
                    ForEach(viewModel.beats) { beat in
                        circle(beat)
                    }
                }
                .frame(height: 80)
                .task(id: context.date) {
                    viewModel.tick()
                }
            }

            HStack(spacing: 24) {
                DraggableTempoControl(
                    tempo: .init(
                        get: { viewModel.tempo },
                        set: { newTempo in viewModel.tempoChanged(tempo: newTempo) }
                    ),
                    range: 40...240
                )
                PlayButton(state: viewModel.playButtonState) {
                    viewModel.playStopTapped()
                }
            }

            ClickSamplePicker(
                selection: Binding(
                    get: { viewModel.clickSample },
                    set: { newSample in
                        viewModel.clickSampleChanged(clickSample: newSample)
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

struct Beat: Identifiable, Equatable {
    let id: Int
    let highlighted: Bool
}

extension [Beat] {
    static func bar(highlighting beat: Int?) -> [Beat] {
        (0..<BeatsPerBar.value).map { Beat(id: $0, highlighted: $0 == beat) }
    }
}
