import Foundation
import SwiftData

@Model
final class Note {
    var content: String
    var summary: String
    var colorIndex: Int
    var creationDate: Date
    var job: Job?  // Single inverse relationship for all Job relationships

    init(content: String, summary: String, colorIndex: Int) {
        self.content = content
        self.summary = summary
        self.colorIndex = colorIndex
        self.creationDate = Date()
    }
}
