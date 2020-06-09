import Foundation

struct SuggestionProperties: Equatable {
    let description: String
    let projectID: Double?
    let taskID: Double?
    let projectColor: String
    let projectName: String
    let taskName: String
    let clientName: String
    let hasProject: Bool
    let hasClient: Bool
    let hasTask: Bool
    let workspaceId: Double
    let isBillable: Bool
    let tagIds: [Double]
    let startTime: Date
    let duration: TimeInterval
}

enum LogSuggestion {
    case mostUsed(SuggestionProperties)
    case calendar(SuggestionProperties)
}

extension LogSuggestion: Equatable { }
