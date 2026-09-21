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
    private let engine: MetronomeEngineType

    static let live = Dependencies(engine: MetronomeEngine.Dependencies.live.engine)

    @MainActor func makeMetronomeViewModel() -> MetronomeViewModelType {
        MetronomeViewModel(engine: engine)
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
