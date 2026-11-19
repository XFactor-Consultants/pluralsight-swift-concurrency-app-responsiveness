import Foundation

nonisolated final class ResultBox: @unchecked Sendable {
    var value = ""
}

nonisolated enum ReportLoader {
    // Simulates a slow report. Suspends instead of blocking.
    static func generate() async -> String {
        try? await Task.sleep(for: .seconds(3))
        return "Report ready"
    }
}
