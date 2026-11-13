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
            await tasksStore.loadAvatars()
        }
        .task {
            let cache = AvatarCache()
            let id = UUID()
            async let first = cache.avatar(for: id)
            async let second = cache.avatar(for: id)
            _ = await (first, second)
            print("Loads: \(await cache.loadCount)")
        }
        // Rebuilds the index every time the app becomes active, including at launch.
        // This is the second "Build Search Index" before the first frame.
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            if newPhase == .active {
                Task { await tasksStore.rebuildSearchIndex() }
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
