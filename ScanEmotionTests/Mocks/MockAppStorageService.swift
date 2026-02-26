//
//  MockAppStorageService.swift
//  ScanEmotionTests
//

import Foundation
@testable import ScanEmotion

final class MockAppStorageService: AppStorageServiceProtocol {
    private var store: [String: Any] = [:]
    var resetAllCallCount = 0

    func set(_ value: some Any, forKey key: AppStorageKeys) {
        store[key.rawValue] = value
    }

    func value<T>(forKey key: AppStorageKeys) -> T? {
        store[key.rawValue] as? T
    }

    func reset(forKey key: AppStorageKeys) {
        store.removeValue(forKey: key.rawValue)
    }

    func resetAll() {
        resetAllCallCount += 1
        store.removeAll()
    }
}
