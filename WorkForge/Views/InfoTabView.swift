//
//  InfoTabView.swift
//  WorkForge
//
//  Created by Ryan Bliss on 9/4/25.
//


import SwiftUI
import SwiftData

struct InfoTabView: View {
    var job: Job
    @Environment(\.modelContext) private var modelContext
    @State private var email: String = ""
    @State private var payRate: Double = 0.0
    @State private var payType: String = "Hourly"
    @State private var managerName: String = ""
    @State private var roleTitle: String = ""
    @State private var equipmentList: String = ""
    @State private var jobType: String = "Full-time"
    @State private var contractEndDate: Date? = nil
    @State private var showEditForm = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Job Information")
                .font(.title2)
                .bold()
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if !email.isEmpty {
                        Text("Email: \(email)")
                    }
                    if payRate > 0 {
                        Text("Pay Rate: \(payRate, format: .currency(code: "USD")) per \(payType)")
                    }
                    if !managerName.isEmpty {
                        Text("Manager: \(managerName)")
                    }
                    if !roleTitle.isEmpty {
                        Text("Role/Title: \(roleTitle)")
                    }
                    if !equipmentList.isEmpty {
                        Text("Equipment/Assets: \(equipmentList)")
                    }
                    Text("Job Type: \(jobType)")
                    if jobType == "Contracted", let endDate = contractEndDate {
                        Text("Contract Ends: \(endDate, format: .dateTime.month(.twoDigits).day(.twoDigits).year(.defaultDigits))")
                    }

                    Button("Edit") {
                        showEditForm = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .sheet(isPresented: $showEditForm) {
                NavigationView {
                    Form {
                        Section(header: Text("Job Information")) {
                            TextField("Email", text: $email)
                            TextField("Pay Rate", value: $payRate, format: .number)
                                .keyboardType(.decimalPad)
                            Picker("Pay Type", selection: $payType) {
                                Text("Hourly").tag("Hourly")
                                Text("Yearly").tag("Yearly")
                            }
                            TextField("Manager Name", text: $managerName)
                            TextField("Role/Title", text: $roleTitle)
                            TextField("Equipment/Assets List", text: $equipmentList, axis: .vertical)
                                .lineLimit(3, reservesSpace: true)
                            Picker("Job Type", selection: $jobType) {
                                Text("Part-time").tag("Part-time")
                                Text("Full-time").tag("Full-time")
                                Text("Temporary").tag("Temporary")
                                Text("Contracted").tag("Contracted")
                            }
                            if jobType == "Contracted" {
                                DatePicker("Contract End Date", selection: Binding(
                                    get: { contractEndDate ?? Date() },
                                    set: { contractEndDate = $0 }
                                ), displayedComponents: [.date])
                            }
                        }
                        Section {
                            Button("Save") {
                                saveJobInfo()
                                showEditForm = false
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(.blue.opacity(0.8))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .navigationTitle("Edit Job Info")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                loadJobInfo()
                                showEditForm = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadJobInfo()
            }
        }
    }

    private func loadJobInfo() {
        email = job.email ?? ""
        payRate = job.payRate
        payType = job.payType ?? "Hourly"
        managerName = job.managerName ?? ""
        roleTitle = job.roleTitle ?? ""
        equipmentList = job.equipmentList ?? ""
        jobType = job.jobType ?? "Full-time"
        contractEndDate = job.contractEndDate
    }

    private func saveJobInfo() {
        job.email = email
        job.payRate = payRate
        job.payType = payType
        job.managerName = managerName
        job.roleTitle = roleTitle
        job.equipmentList = equipmentList
        job.jobType = jobType
        job.contractEndDate = contractEndDate
        try? modelContext.save()
    }
}

struct InfoTabView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Job.self, configurations: config)
            return InfoTabView(job: Job(title: "Preview Job"))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}