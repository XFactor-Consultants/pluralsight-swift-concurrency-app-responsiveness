import SwiftUI

struct LeakView: View {
    var body: some View {
        Text("This screen starts a background job when it appears.")
            .multilineTextAlignment(.center)
            .padding()
            .navigationTitle("Leak")
            .task  {
                TaskMonitor.shared.taskStarted()
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1))
                }
                TaskMonitor.shared.taskEnded()
            }
    }
}
