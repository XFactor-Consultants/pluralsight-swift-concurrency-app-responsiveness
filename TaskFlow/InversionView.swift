import SwiftUI

struct InversionView: View {
    @State private var report = "No report yet"

    var body: some View {
        VStack(spacing: 16) {
            Text(report)
                .font(.headline)
            Button("Load Report") {
                Task { report = await ReportLoader.generate() }
            }
            .buttonStyle(.borderedProminent)
            // Something to scroll, so a frozen screen is obvious.
            List(0..<40, id: \.self) { row in
                Text("Row \(row)")
            }
        }
        .padding(.top)
        .navigationTitle("Inversion")
    }
}
