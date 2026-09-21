//
//  PlayButton.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct PlayButton: View {
    let state: PlayButtonState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: state == .play ? "play.fill" : "stop.fill")
                .font(.largeTitle)
        }
    }
}
