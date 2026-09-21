//
//  ClickSamplePicker.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.04.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct ClickSamplePicker: View {
    @Binding var selection: ClickSample

    var body: some View {
        Picker("Click Sample", selection: $selection) {
            ForEach(ClickSample.allCases) { option in
                Text(option.description).tag(option)
            }
        }
        .pickerStyle(.automatic)
    }
}
