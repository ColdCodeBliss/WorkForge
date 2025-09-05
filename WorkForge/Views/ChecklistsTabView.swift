import SwiftUI
import SwiftData

struct ChecklistsTabView: View {
    @Binding var newChecklistItem: String
    var job: Job
    @Environment(\.modelContext) private var modelContext
    @State private var isCompletedSectionExpanded: Bool = false
    @State private var showAddChecklistForm: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Button(action: { showAddChecklistForm = true }) {
                Text("Add Checklist Item")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            if showAddChecklistForm {
                checklistForm
            }

            checklistsList
        }
        .background(Gradient(colors: [.blue, .purple]).opacity(0.1))
        .onAppear {
            showAddChecklistForm = false
        }
    }

    @ViewBuilder
    private var checklistForm: some View {
        VStack {
            Text("Add Checklist Item")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            TextField("Item Description", text: $newChecklistItem)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            HStack {
                Button(action: {
                    showAddChecklistForm = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.trailing)

                Button(action: addChecklistItem) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(newChecklistItem.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    @ViewBuilder
    private var checklistsList: some View {
        List {
            Section(header: Text("Active Checklists")) {
                ForEach(job.checklistItems.filter { !$0.isCompleted }) { item in
                    HStack {
                        Circle()
                            .fill(priorityColor(for: item.priority))
                            .frame(width: 10, height: 10)
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            item.isCompleted = true
                            item.completionDate = Date()
                            do {
                                try modelContext.save()
                            } catch {
                                print("Save error: \(error)")
                            }
                        } label: {
                            Label("Mark Completed", systemImage: "checkmark")
                        }
                        .tint(.green)

                        Menu {
                            Button("Red: Urgent") { item.priority = "Red"; try? modelContext.save() }
                            Button("Green: Standard") { item.priority = "Green"; try? modelContext.save() }
                            Button("Yellow: Ideas") { item.priority = "Yellow"; try? modelContext.save() }
                        } label: {
                            Label("Color", systemImage: "paintpalette")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = job.checklistItems.firstIndex(of: item) {
                                job.checklistItems.remove(at: index)
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Save error: \(error)")
                                }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            Section {
                DisclosureGroup(isExpanded: $isCompletedSectionExpanded) {
                    ForEach(job.checklistItems.filter { $0.isCompleted }) { item in
                        HStack {
                            Circle()
                                .fill(priorityColor(for: item.priority))
                                .frame(width: 10, height: 10)
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            if let completionDate = item.completionDate {
                                Text("Completed: \(formattedDate(completionDate))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                item.isCompleted = false
                                item.completionDate = nil
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Save error: \(error)")
                                }
                            } label: {
                                Label("Unmark", systemImage: "arrow.uturn.left")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let index = job.checklistItems.firstIndex(of: item) {
                                    job.checklistItems.remove(at: index)
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("Save error: \(error)")
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } label: {
                    Text("Completed Checklists (\(job.checklistItems.filter { $0.isCompleted }.count))")
                        .font(.headline)
                }
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
    }

    private func addChecklistItem() {
        withAnimation {
            let newItem = ChecklistItem(title: newChecklistItem)
            job.checklistItems.append(newItem)
            newChecklistItem = ""
            do {
                try modelContext.save()
            } catch {
                print("Save error: \(error)")
            }
            showAddChecklistForm = false
        }
    }

    private func priorityColor(for priority: String) -> Color {
        switch priority {
        case "Red": return .red
        case "Yellow": return .yellow
        case "Green": return .green
        default: return .green
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    ChecklistsTabView(
        newChecklistItem: .constant(""),
        job: Job(title: "Preview Job")
    )
    .modelContainer(for: [Job.self, ChecklistItem.self], inMemory: true)
}
