//Git Push Testing
//Testing 2

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Job> { !$0.isDeleted }) private var jobs: [Job]
    @Query(filter: #Predicate<Job> { $0.isDeleted }) private var deletedJobs: [Job]
    @Environment(\.modelContext) private var modelContext
    @State private var isRenaming = false
    @State private var jobToRename: Job?
    @State private var newJobTitle = ""
    @State private var showJobHistory = false
    @State private var jobToDeletePermanently: Job? = nil

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(jobs) { job in
                        NavigationLink(destination: JobDetailView(job: job)) {
                            VStack(alignment: .leading) {
                                Text(job.title)
                                    .font(.headline)
                                Text("Created: \(job.creationDate, format: .dateTime)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .swipeActions(edge: .leading) {
                            Button(action: {
                                jobToRename = job
                                newJobTitle = job.title
                                isRenaming = true
                            }) {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                job.isDeleted = true
                                job.deletionDate = Date()
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteJob)
                }
                .navigationTitle("WorkForge Stack")
                .toolbar {
                    Button("Add Job", systemImage: "plus") { addJob() }
                }
                .scrollContentBackground(.hidden)
                .background(Gradient(colors: [.blue, .purple]).opacity(0.1))
                .alert("Rename Job", isPresented: $isRenaming) {
                    TextField("New Title", text: $newJobTitle)
                    Button("Cancel", role: .cancel) {
                        isRenaming = false
                        jobToRename = nil
                        newJobTitle = ""
                    }
                    Button("Save") {
                        if let job = jobToRename, !newJobTitle.isEmpty {
                            job.title = newJobTitle
                            try? modelContext.save()
                        }
                        isRenaming = false
                        jobToRename = nil
                        newJobTitle = ""
                    }
                }
                .alert("Confirm Permanent Deletion", isPresented: Binding(
                    get: { jobToDeletePermanently != nil },
                    set: { if !$0 { jobToDeletePermanently = nil } }
                )) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete Permanently", role: .destructive) {
                        if let job = jobToDeletePermanently {
                            modelContext.delete(job)
                            try? modelContext.save()
                        }
                    }
                } message: {
                    Text("This action cannot be undone.")
                }

                if !deletedJobs.isEmpty {
                    Button(action: { showJobHistory = true }) {
                        HStack {
                            Text("Job History")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.blue)
                    }
                    .padding()
                    .sheet(isPresented: $showJobHistory) {
                        NavigationView {
                            List {
                                ForEach(deletedJobs) { job in
                                    VStack(alignment: .trailing) {
                                        Text(job.title)
                                            .font(.headline)
                                        Text("Deleted: \(job.deletionDate ?? Date(), format: .dateTime)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            jobToDeletePermanently = job
                                        } label: {
                                            Label("Total Deletion", systemImage: "trash.fill")
                                        }
                                    }
                                }
                            }
                            .navigationTitle("Job History")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showJobHistory = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func addJob() {
        let jobCount = jobs.count + 1
        let newJob = Job(title: "Job \(jobCount)")
        modelContext.insert(newJob)
    }

    private func deleteJob(at offsets: IndexSet) {
        for offset in offsets {
            let job = jobs[offset]
            job.isDeleted = true
            job.deletionDate = Date()
        }
        try? modelContext.save()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Job.self, inMemory: true)
}
