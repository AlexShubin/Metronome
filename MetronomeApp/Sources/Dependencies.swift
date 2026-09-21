//
//  Dependencies.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import MetronomeEngine
import SwiftUI

struct Dependencies {
    private let metronome: MetronomeType

    static let live = Dependencies(metronome: MetronomeEngine.Dependencies.live.makeMetronome())

    @MainActor func makeMetronomeViewModel() -> MetronomeViewModelType {
        MetronomeViewModel(metronome: metronome)
    }
}

// MARK: - Environment

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue = Dependencies.live
}

extension EnvironmentValues {
    var dependencies: Dependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}
