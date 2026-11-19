import SwiftUI

struct DiagnosticsView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Background tasks", value: "\(TaskMonitor.shared.activeTasks)")
            }
            Section("Scenarios") {
                NavigationLink("Race") { RaceView() }
                NavigationLink("Inversion") { InversionView() }
                NavigationLink("Leak") { LeakView() }
            }
        }
        .navigationTitle("Diagnostics")
    }
}

#Preview {
    NavigationStack {
        DiagnosticsView()
    }
}
