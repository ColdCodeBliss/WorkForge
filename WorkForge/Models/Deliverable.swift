import Foundation
import SwiftData
import UserNotifications

@Model
final class Deliverable {
    var taskDescription: String
    var dueDate: Date
    var isCompleted: Bool = false
    var completionDate: Date? = nil
    var job: Job?
    var colorCode: String? = "gray"  // Store color as a string (e.g., "gray", "red", "blue")
    var reminderOffsets: [String]    // Store reminder offsets (e.g., "2weeks", "1week", "2days", "dayof")

    init(taskDescription: String, dueDate: Date) {
        self.taskDescription = taskDescription
        self.dueDate = dueDate
        self.reminderOffsets = []
    }
}
