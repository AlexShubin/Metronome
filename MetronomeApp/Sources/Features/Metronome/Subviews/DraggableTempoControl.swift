//
//  DraggableTempoControl.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct DraggableTempoControl: View {
    @Binding var tempo: Int
    let range: ClosedRange<Int>

    @State private var dragStartTempo: Int?

    private let pointsPerStep: CGFloat = 20

    var body: some View {
        HStack(spacing: 4) {
            Text("\(tempo)")
                .font(.system(size: 48, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())

            VStack(spacing: 2) {
                Image(systemName: "arrowtriangle.up.fill")
                Image(systemName: "arrowtriangle.down.fill")
            }
            .font(.system(size: 8))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragStartTempo == nil {
                        dragStartTempo = tempo
                    }
                    let delta = Int(-value.translation.height / pointsPerStep)
                    let newTempo = (dragStartTempo ?? tempo) + delta

                    let newFinalTempo = min(max(newTempo, range.lowerBound), range.upperBound)
                    if newFinalTempo != tempo {
                        withAnimation(.snappy(duration: 0.15)) {
                            tempo = newFinalTempo
                        }
                    }
                }
                .onEnded { _ in
                    dragStartTempo = nil
                }
        )
    }
}
