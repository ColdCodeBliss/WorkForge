import Foundation
import SwiftData

@Model
final class ChecklistItem {
    var title: String
    var isCompleted: Bool = false
    var completionDate: Date? = nil
    var priority: String = "Green"  // "Green", "Red", "Yellow"
    var job: Job?  // Inverse relationship to Job

    init(title: String) {
        self.title = title
    }
}
