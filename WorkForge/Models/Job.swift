import Foundation
import SwiftData

@Model
final class Job {
    var title: String
    var creationDate: Date
    var isDeleted: Bool = false
    var deletionDate: Date? = nil
    @Relationship(deleteRule: .cascade, inverse: \Deliverable.job) var deliverables: [Deliverable] = []
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.job) var checklistItems: [ChecklistItem] = []
    @Relationship(deleteRule: .cascade, inverse: \Note.job) var notes: [Note] = []
    var email: String?
    var payRate: Double = 0.0
    var payType: String? = "Hourly"  // "Hourly" or "Yearly"
    var managerName: String?
    var roleTitle: String?
    var equipmentList: String?
    var jobType: String? = "Full-time"  // "Part-time", "Full-time", "Temporary", "Contracted"
    var contractEndDate: Date?

    init(title: String) {
        self.title = title
        self.creationDate = Date()
    }
}
