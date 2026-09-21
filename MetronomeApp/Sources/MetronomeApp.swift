//
//  MetronomeApp.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

@main
struct MetronomeApp: App {
    @Environment(\.dependencies) private var dependencies

    var body: some Scene {
        Window("Metronome", id: "metronome") {
            MetronomeView(viewModel: dependencies.makeMetronomeViewModel())
        }
        .windowResizability(.contentSize)
    }
}
