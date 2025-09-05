import SwiftUI
import SwiftData

@main
struct WorkForgeApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: [Job.self, Deliverable.self, ChecklistItem.self, Note.self])
        }
    }
}
