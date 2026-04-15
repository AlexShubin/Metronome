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
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 12) {
                HStack(spacing: 40) {
                    ForEach(viewModel.state.beats) {
                        circle(highlighted: $0.highlighted)
                    }
                }
                .frame(height: 80)

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.accept(action: .settingsTapped) }
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(item: $viewModel.destination) { destination in
                switch destination {
                case .settings:
                    SettingsView(viewModel: dependencies.makeSettingsViewModel())
                }
            }
        }
    }

    @ViewBuilder
    private func circle(highlighted: Bool) -> some View {
        let size: CGFloat = highlighted ? 35 : 25

        ZStack {
            Color.clear
                .frame(width: 40, height: 40)
            Circle()
                .fill(highlighted ? .red : .blue)
                .frame(width: size, height: size)
                .animation(.linear(duration: 0.1), value: viewModel.state.beats)
        }
    }
}

// MARK: - View State

struct MetronomeViewState: Equatable {
    struct Beat: Identifiable, Equatable {
        let id: Int
        let highlighted: Bool
    }

    var tempo: Int
    var clickSample: ClickSampleViewState
    var beats: [Beat]
    var playButtonState: PlayButtonViewState

    static let initial = MetronomeViewState(
        tempo: 120,
        clickSample: .classic,
        beats: [
            .init(id: 0, highlighted: false),
            .init(id: 1, highlighted: false),
            .init(id: 2, highlighted: false),
            .init(id: 3, highlighted: false),
        ],
        playButtonState: .play
    )
}

// MARK: - Preview

@MainActor @Observable
private class PreviewMetronomeViewModel: MetronomeViewModelType {
    var state = MetronomeViewState(
        tempo: 120,
        clickSample: .classic,
        beats: [
            .init(id: 0, highlighted: true),
            .init(id: 1, highlighted: false),
            .init(id: 2, highlighted: false),
            .init(id: 3, highlighted: false),
        ],
        playButtonState: .play
    )
    var destination: MetronomeDestination?

    func accept(action: MetronomeViewModelAction) async {}
}

#Preview {
    MetronomeView(viewModel: PreviewMetronomeViewModel())
}
