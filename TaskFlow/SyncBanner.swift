import SwiftUI
 
struct SyncBanner: View {
    @State private var lastSync: Date?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .symbolEffect(.pulse, options: .repeating)
            Text(lastSync.map { "Synced at \($0.formatted(date: .omitted, time: .standard))" } ?? "Waiting for first sync")
        }
        .font(.caption)
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.bar)
        .task {
            for await date in SyncEngine.shared.events() {
                lastSync = date
            }
        }
    }
}
