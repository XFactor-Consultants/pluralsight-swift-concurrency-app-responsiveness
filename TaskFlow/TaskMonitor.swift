import Observation

// Counts how many background jobs are running, so the Diagnostics screen can show it.
@Observable
final class TaskMonitor {
    static let shared = TaskMonitor()

    private(set) var activeTasks = 0

    func taskStarted() {
        activeTasks += 1
    }

    func taskEnded() {
        activeTasks -= 1
    }
}
