import SwiftUI
import UIKit

struct RootView: View {
    @Environment(TasksStore.self) private var tasksStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Tasks", systemImage: "checklist") {
                TaskListView()
            }
            Tab("Activity", systemImage: "bolt") {
                ActivityView()
            }
            Tab("History", systemImage: "clock") {
                HistoryView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .task {
            SyncEngine.shared.startSyncLoop()
        }
        // Rebuilds the index every time the app becomes active, including at launch.
        // This is the second "Build Search Index" before the first frame.
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            if newPhase == .active {
                tasksStore.rebuildSearchIndex()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            tasksStore.avatarCache.removeAll()
        }
    }
}

#Preview {
    RootView()
        .environment(TasksStore())
        .environment(ActivityStore())
}
