import SwiftUI
import SwiftData
import UserNotifications

struct DueTabView: View {
    @Binding var newTaskDescription: String
    @Binding var newDueDate: Date
    @Binding var isCompletedSectionExpanded: Bool
    var job: Job
    @Environment(\.modelContext) private var modelContext
    @State private var showAddDeliverableForm = false
    @State private var showCompletedDeliverables = false
    @State private var deliverableToDeletePermanently: Deliverable? = nil
    @State private var selectedDeliverable: Deliverable? = nil
    @State private var showColorPicker = false
    @State private var showReminderPicker = false

    var body: some View {
        VStack(spacing: 16) {
            Button(action: { showAddDeliverableForm = true }) {
                Text("Add Deliverable")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            if showAddDeliverableForm {
                deliverableForm
            }

            deliverablesList

            if !completedDeliverables.isEmpty {
                Button(action: { showCompletedDeliverables = true }) {
                    HStack {
                        Text("Completed Deliverables")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.blue)
                }
                .padding()
                .sheet(isPresented: $showCompletedDeliverables) {
                    completedDeliverablesView
                }
            }
        }
        .background(Gradient(colors: [.blue, .purple]).opacity(0.1))
        .onAppear {
            showAddDeliverableForm = false
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    print("Notification permission granted")
                }
            }
        }
        .alert("Confirm Permanent Deletion", isPresented: Binding(
            get: { deliverableToDeletePermanently != nil },
            set: { if !$0 { deliverableToDeletePermanently = nil } }
        )) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Permanently", role: .destructive) {
                if let deliverable = deliverableToDeletePermanently {
                    modelContext.delete(deliverable)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Save error: \(error)")
                    }
                    removeAllNotifications(for: deliverable)
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(selectedDeliverable: $selectedDeliverable, isPresented: $showColorPicker)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showReminderPicker) {
            ReminderPickerView(selectedDeliverable: $selectedDeliverable, isPresented: $showReminderPicker)
                .presentationDetents([.medium])
        }
    }

    var completedDeliverables: [Deliverable] {
        job.deliverables.filter { $0.isCompleted }
    }

    @ViewBuilder
    private var deliverableForm: some View {
        VStack {
            Text("Add Deliverable")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            TextField("Task Description", text: $newTaskDescription)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            DatePicker("Due Date", selection: $newDueDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .padding(.horizontal)
            HStack {
                Button(action: {
                    showAddDeliverableForm = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.trailing)

                Button(action: {
                    let newDeliverable = Deliverable(taskDescription: newTaskDescription, dueDate: newDueDate)
                    job.deliverables.append(newDeliverable)
                    newTaskDescription = ""
                    newDueDate = Date()
                    do {
                        try modelContext.save()
                    } catch {
                        print("Save error: \(error)")
                    }
                    showAddDeliverableForm = false
                }) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(newTaskDescription.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    @ViewBuilder
    private var deliverablesList: some View {
        List {
            activeDeliverablesSection
        }
        .scrollContentBackground(.hidden)
        .animation(.spring(duration: 0.3), value: job.deliverables)
    }

    @ViewBuilder
    private var activeDeliverablesSection: some View {
        Section(header: Text("Active Deliverables")) {
            ForEach(job.deliverables.filter { !$0.isCompleted }) { deliverable in
                HStack {
                    VStack(alignment: .leading) {
                        Text(deliverable.taskDescription)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        DatePicker("Due", selection: Binding(
                            get: { deliverable.dueDate },
                            set: { newValue in
                                deliverable.dueDate = newValue
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Save error: \(error)")
                                }
                                updateNotifications(for: deliverable)
                            }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        selectedDeliverable = deliverable
                        showReminderPicker = true
                    }) {
                        Image(systemName: "bell")
                            .foregroundColor(.black) // Changed from .gray to .black
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color(for: deliverable.colorCode))
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        deliverable.isCompleted = true
                        deliverable.completionDate = Date()
                        do {
                            try modelContext.save()
                        } catch {
                            print("Save error: \(error)")
                        }
                        removeAllNotifications(for: deliverable)
                    } label: {
                        Label("Mark Complete", systemImage: "checkmark")
                    }
                    .tint(.green)
                    Button {
                        selectedDeliverable = deliverable
                        showColorPicker = true
                    } label: {
                        Label("Change Color", systemImage: "paintbrush")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        if let index = job.deliverables.firstIndex(of: deliverable) {
                            job.deliverables.remove(at: index)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Save error: \(error)")
                            }
                            removeAllNotifications(for: deliverable)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: { offsets in
                for offset in offsets.reversed() {
                    let deliverable = job.deliverables[offset]
                    if !deliverable.isCompleted {
                        job.deliverables.remove(at: offset)
                        removeAllNotifications(for: deliverable)
                    }
                }
                do {
                    try modelContext.save()
                } catch {
                    print("Save error: \(error)")
                }
            })
        }
    }

    @ViewBuilder
    private var completedDeliverablesView: some View {
        NavigationView {
            List {
                ForEach(completedDeliverables, id: \.self) { deliverable in
                    VStack(alignment: .leading) {
                        Text(deliverable.taskDescription)
                            .font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Completed: \(formattedDate(deliverable.completionDate ?? Date()))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color(for: deliverable.colorCode))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deliverableToDeletePermanently = deliverable
                        } label: {
                            Label("Total Deletion", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .navigationTitle("Completed Deliverables")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showCompletedDeliverables = false
                    }
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }

    private func color(for colorCode: String?) -> Color {
        switch colorCode?.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        default: return .gray
        }
    }
}

// Notification utility functions
fileprivate func updateNotifications(for deliverable: Deliverable) {
    removeAllNotifications(for: deliverable)
    guard !deliverable.reminderOffsets.isEmpty else { return }
    let content = UNMutableNotificationContent()
    content.title = "Deliverable Reminder"
    content.body = "\(deliverable.taskDescription) is due on \(formattedDate(deliverable.dueDate))"
    content.sound = UNNotificationSound.default

    for offset in deliverable.reminderOffsets {
        if let triggerDate = calculateTriggerDate(for: offset, dueDate: deliverable.dueDate), triggerDate > Date() {
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
            let request = UNNotificationRequest(identifier: "\(deliverable.persistentModelID)-\(offset)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
}

fileprivate func removeAllNotifications(for deliverable: Deliverable) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: deliverable.reminderOffsets.map { "\(deliverable.persistentModelID)-\($0)" })
}

fileprivate func calculateTriggerDate(for offset: String, dueDate: Date) -> Date? {
    let calendar = Calendar.current
    switch offset.lowercased() {
    case "2weeks": return calendar.date(byAdding: .day, value: -14, to: dueDate)
    case "1week": return calendar.date(byAdding: .day, value: -7, to: dueDate)
    case "2days": return calendar.date(byAdding: .day, value: -2, to: dueDate)
    case "dayof": return dueDate
    default: return nil
    }
}

fileprivate func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
}

struct ColorPickerView: View {
    @Binding var selectedDeliverable: Deliverable?
    @Binding var isPresented: Bool
    let colors: [String] = ["red", "blue", "green", "yellow", "orange", "purple", "pink", "teal"]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Color")
                    .font(.title2)
                    .bold()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                    ForEach(colors, id: \.self) { colorName in
                        Button(action: {
                            if let deliverable = selectedDeliverable {
                                deliverable.colorCode = colorName
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Save error: \(error)")
                                }
                                isPresented = false
                            }
                        }) {
                            Circle()
                                .fill(color(for: colorName))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                        .opacity(selectedDeliverable?.colorCode == colorName ? 1 : 0)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Color Picker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func color(for colorCode: String) -> Color {
        switch colorCode.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        default: return .gray
        }
    }
}

struct ReminderPickerView: View {
    @Binding var selectedDeliverable: Deliverable?
    @Binding var isPresented: Bool
    let reminderOptions: [String] = ["2 weeks", "1 week", "2 days", "day of"]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set Reminders")
                    .font(.title2)
                    .bold()
                List {
                    ForEach(reminderOptions, id: \.self) { option in
                        Button(action: {
                            var offsets = selectedDeliverable?.reminderOffsets ?? []
                            let normalizedOffset = option.lowercased().replacingOccurrences(of: " ", with: "")
                            if offsets.contains(normalizedOffset) {
                                offsets.removeAll { $0 == normalizedOffset }
                            } else {
                                offsets.append(normalizedOffset)
                            }
                            if let deliverable = selectedDeliverable {
                                deliverable.reminderOffsets = offsets
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Save error: \(error)")
                                }
                                updateNotifications(for: deliverable)
                            }
                        }) {
                            HStack {
                                Image(systemName: (selectedDeliverable?.reminderOffsets.contains(option.lowercased().replacingOccurrences(of: " ", with: "")) ?? false) ? "checkmark.square.fill" : "square")
                                Text(option)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Reminder Options")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        if let deliverable = selectedDeliverable {
                            updateNotifications(for: deliverable)
                        }
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct DueTabView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Job.self, Deliverable.self, configurations: config)
            let job = Job(title: "Preview Job")
            return DueTabView(
                newTaskDescription: .constant(""),
                newDueDate: .constant(Date()),
                isCompletedSectionExpanded: .constant(false),
                job: job
            )
            .modelContainer(container)
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
