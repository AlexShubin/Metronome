//
//  Dependencies.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct Dependencies {
    static let live = Dependencies()

    @MainActor func makeMetronomeViewModel() -> MetronomeViewModelType {
        MetronomeViewModel(engine: MetronomeEngine())
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
