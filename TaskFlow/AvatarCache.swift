//
//  AvatarCache.swift
//  TaskFlow
//
//

import Foundation

actor AvatarCache {
    private var storage: [UUID: Data] = [:]
    
    private(set) var loadCount = 0
    
    private var inFlight: [UUID: Task<Data, Never>] = [:]
    
    
    var count: Int { storage.count }
    
    func store(_ data: Data, for id: UUID) {
        storage[id] = data
    }
    
    func avatar(for id: UUID) async -> Data {
        if let cached = storage[id] { return cached }
        if let existing = inFlight[id] { return await existing.value }
        
        let task = Task { await load(id) }
        inFlight[id] = task
        let data = await task.value
        storage[id] = data
        inFlight[id] = nil
        return data
    }
     
    private func load(_ id: UUID) async -> Data {
        loadCount += 1
        try? await Task.sleep(for: .milliseconds(200))
        return Data(id.uuidString.utf8)
    }
}
