import SwiftUI
import SwiftData

struct JobDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var newTaskDescription: String = ""
    @State private var newDueDate: Date = Date()
    @State private var newChecklistItem: String = ""
    @State private var isCompletedSectionExpanded: Bool = false
    var job: Job

    var body: some View {
        TabView {
            DueTabView(
                newTaskDescription: $newTaskDescription,
                newDueDate: $newDueDate,
                isCompletedSectionExpanded: $isCompletedSectionExpanded,
                job: job
            )
            .tabItem { Label("Due", systemImage: "calendar") }

            ChecklistsTabView(
                newChecklistItem: $newChecklistItem,
                job: job
            )
            .tabItem { Label("Checklist", systemImage: "checkmark.square") }

            NotesTabView(job: job)
                .tabItem { Label("Notes", systemImage: "note.text") }

            InfoTabView(job: job)
                .tabItem { Label("Info", systemImage: "info.circle") }
        }
        .navigationTitle(job.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addDeliverable() {
        withAnimation {
            let newDeliverable = Deliverable(taskDescription: newTaskDescription, dueDate: newDueDate)
            job.deliverables.append(newDeliverable)
            newTaskDescription = ""
            newDueDate = Date()
            try? modelContext.save()
        }
    }

    private func deleteDeliverable(at offsets: IndexSet) {
        withAnimation {
            for offset in offsets.reversed() {
                let deliverable = job.deliverables[offset]
                if !deliverable.isCompleted {
                    job.deliverables.remove(at: offset)
                }
            }
            try? modelContext.save()
        }
    }

    private func deleteCompletedDeliverable(at offsets: IndexSet) {
        withAnimation {
            for offset in offsets.reversed() {
                let deliverable = job.deliverables[offset]
                if deliverable.isCompleted {
                    job.deliverables.remove(at: offset)
                }
            }
            try? modelContext.save()
        }
    }

    private func addChecklistItem() {
        withAnimation {
            let newItem = ChecklistItem(title: newChecklistItem)
            job.checklistItems.append(newItem)
            newChecklistItem = ""
            try? modelContext.save()
        }
    }

    private func deleteChecklistItem(at offsets: IndexSet) {
        withAnimation {
            job.checklistItems.remove(atOffsets: offsets)
            try? modelContext.save()
        }
    }
}

struct JobDetailView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Job.self, Deliverable.self, ChecklistItem.self, Note.self, configurations: config)
            return JobDetailView(job: Job(title: "Preview Job"))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
