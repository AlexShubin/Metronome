//
//  ClickSamplePicker.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct ClickSamplePicker: View {
    @Binding var selection: ClickSampleViewState

    var body: some View {
        Picker("Click Sample", selection: $selection) {
            ForEach(ClickSampleViewState.allCases) { option in
                Text(option.description).tag(option)
            }
        }
        .pickerStyle(.automatic)
    }
}

enum ClickSampleViewState: String, CaseIterable, Identifiable, Equatable, CustomStringConvertible {
    case classic
    case digital
    case logicStyle

    var id: String { rawValue }

    var description: String {
        switch self {
        case .classic: "Classic"
        case .digital: "Digital"
        case .logicStyle: "Logic Style"
        }
    }
}

#Preview {
    @Previewable @State var selection: ClickSampleViewState = .classic
    ClickSamplePicker(selection: $selection)
}
