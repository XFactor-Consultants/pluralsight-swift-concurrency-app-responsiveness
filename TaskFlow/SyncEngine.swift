//
//  SyncEngine.swift
//  TaskFlow
//
//  Simulated background sync. The real app has no sync; this stands in for one.
//  Every ten seconds it does real, CPU-heavy work so there is something to
//  reason about. Test scaffolding: remove before real use.
//

import Foundation

final class SyncEngine {
    
    static let shared = SyncEngine()
    
    private var syncTask: Task<Void, Never>?
    private(set) var lastChecksum = 0
    private var continuation: AsyncStream<Date>.Continuation?
    
    
    func startSyncLoop() {
        syncTask?.cancel()
        syncTask = Task.detached {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))
                let checksum = SyncEngine.performSync()
                await SyncEngine.shared.apply(checksum)
            }
        }
    }
    
    func apply(_ checksum: Int) {
        lastChecksum = checksum
        continuation?.yield(.now)
    }
    
    func events() -> AsyncStream<Date> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.continuation = nil
                }
            }
        }
    }
    
    nonisolated static func performSync() -> Int {
        var values = (0..<1_500_000).map { ($0 &* 2_654_435_761) % 1_000_003 }
        values.sort()
        return values[values.count / 2]
    }
}

