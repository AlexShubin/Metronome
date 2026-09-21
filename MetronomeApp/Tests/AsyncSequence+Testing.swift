//
//  AsyncSequence+Testing.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 24.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

extension AsyncSequence {
    func next() async rethrows -> Element? {
        var iterator = makeAsyncIterator()
        return try await iterator.next()
    }
}
