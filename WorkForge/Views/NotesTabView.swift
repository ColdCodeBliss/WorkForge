import SwiftUI
import SwiftData

struct NotesTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingNote = false
    @State private var isEditingNote = false
    @State private var newNoteContent = ""
    @State private var newNoteSummary = ""
    @State private var selectedNote: Note? = nil
    var job: Job

    private let colors: [Color] = [.red, .blue, .green, .orange, .yellow, .purple, .pink, .teal]
    private var nextColorIndex: Int {
        let usedIndices = job.notes.map { $0.colorIndex }
        for index in 0..<colors.count {
            if !usedIndices.contains(index) {
                return index
            }
        }
        return (job.notes.count) % colors.count
    }

    var body: some View {
        VStack(spacing: 16) {
            Button(action: { isAddingNote = true }) {
                Text("New Note")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(job.notes) { note in
                        noteTile(for: note)
                            .onTapGesture {
                                selectedNote = note
                                newNoteContent = note.content
                                newNoteSummary = note.summary
                                isEditingNote = true
                            }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: Binding(
            get: { isAddingNote || isEditingNote },
            set: { if !$0 { isAddingNote = false; isEditingNote = false } }
        )) {
            noteEditor
        }
        .navigationTitle("Notes")
    }

    @ViewBuilder
    private var noteEditor: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Summary (short description)", text: $newNoteSummary)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                TextEditor(text: $newNoteContent)
                    .frame(height: 200)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                Picker("Color", selection: Binding(
                    get: { selectedNote?.colorIndex ?? nextColorIndex },
                    set: { if let note = selectedNote { note.colorIndex = $0; try? modelContext.save() } }
                )) {
                    ForEach(0..<colors.count, id: \.self) { index in
                        Text(colorName(for: index)).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                HStack {
                    Button("Cancel") {
                        isAddingNote = false
                        isEditingNote = false
                        newNoteContent = ""
                        newNoteSummary = ""
                        selectedNote = nil
                    }
                    .foregroundStyle(.red)
                    Button("Save") {
                        if !newNoteContent.isEmpty && !newNoteSummary.isEmpty {
                            if let note = selectedNote {
                                note.content = newNoteContent
                                note.summary = newNoteSummary
                                try? modelContext.save()
                            } else {
                                let newNote = Note(content: newNoteContent, summary: newNoteSummary, colorIndex: nextColorIndex)
                                job.notes.append(newNote)
                                try? modelContext.save()
                            }
                            isAddingNote = false
                            isEditingNote = false
                            newNoteContent = ""
                            newNoteSummary = ""
                            selectedNote = nil
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .navigationTitle(selectedNote != nil ? "Edit Note" : "New Note")
            .navigationBarItems(trailing: Button("Done") {
                isAddingNote = false
                isEditingNote = false
                newNoteContent = ""
                newNoteSummary = ""
                selectedNote = nil
            })
        }
    }

    private func noteTile(for note: Note) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.summary)
                .font(.headline)
                .foregroundStyle(.white)
            Text(note.creationDate, style: .date)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(colors[note.colorIndex].gradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(radius: 5)
    }

    private func colorName(for index: Int) -> String {
        switch index {
        case 0: return "Red"
        case 1: return "Blue"
        case 2: return "Green"
        case 3: return "Orange"
        case 4: return "Yellow"
        case 5: return "Purple"
        case 6: return "Pink"
        case 7: return "Teal"
        default: return "Green"
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Job.self, Deliverable.self, ChecklistItem.self, Note.self, configurations: config)
        return NotesTabView(job: Job(title: "Preview Job"))
            .modelContainer(container)
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}
