import SwiftUI

struct RaceView: View {
    @State private var result = "Not run yet"

    var body: some View {
        VStack(spacing: 24) {
            Text("Two thousand tasks each add one to a shared counter.")
                .multilineTextAlignment(.center)
            Text(result)
                .font(.title3.monospacedDigit())
            Button("Run") {
                Task {
                    let counter = RaceCounter()
                    await withTaskGroup(of: Void.self) { group in
                        for _ in 0..<2_000 {
                            group.addTask { await counter.increment() }
                        }
                    }
                    result = "Counted \(await counter.value) of 2000"
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Race")
    }
}
