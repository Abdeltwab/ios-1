import Foundation
import Models

public enum StartEditAction: Equatable {
    case durationInputted(TimeInterval)
    case descriptionEntered(String, Int)
    case closeButtonTapped
    case dialogDismissed
    case doneButtonTapped
    case startButtonTapped
    case stopButtonTapped
    case timeEntryStarted(startedTimeEntry: TimeEntry, stoppedTimeEntry: TimeEntry?)
    case timeEntryUpdated(TimeEntry)
    
    case autocompleteSuggestionTapped(AutocompleteSuggestion)
    
    case dateTimePicked(Date)
    case dateTimePickingCancelled
    case wheelStartTimeChanged(Date)
    case wheelDurationChanged(TimeInterval)
    case wheelStartAndDurationChanged(Date, TimeInterval)

    case projectButtonTapped
    case addProjectChipTapped
    case tagButtonTapped
    case addTagChipTapped
    case billableButtonTapped
    
    case tagCreated(Tag)

    case setError(ErrorType)
    case autocompleteSuggestionsUpdated([AutocompleteSuggestion])
}

extension StartEditAction: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
            
        case let .descriptionEntered(description, position):
            return "DescriptionEntered \(description), cursor position \(position)"

        case .closeButtonTapped:
            return "CloseButtonTapped"

        case .dialogDismissed:
            return "DialogDismissed"

        case .doneButtonTapped:
            return "DoneButtonTapped"

        case .startButtonTapped:
            return "StartButtonTapped"

        case .stopButtonTapped:
            return "StopButtonTapped"

        case let .timeEntryStarted(startedTimeEntry, stoppedTimeEntry):
            return "TimeEntryStarted: \(startedTimeEntry.description) stopped: \(stoppedTimeEntry?.description ?? "nil")"
            
        case let .timeEntryUpdated(timeEntry):
            return "TimeEntryUpdated: \(timeEntry.description)"
            
        case let .autocompleteSuggestionTapped(suggestion):
            return "AutocompleteSuggestionTapped \(suggestion)"
            
        case let .dateTimePicked(date):
            return "dateTimePicked \(date)"

        case .dateTimePickingCancelled:
            return "DateTimePickingCancelled"

        case .wheelStartTimeChanged(let startDate):
            return "wheelStartTimeChanged \(startDate)"

        case .wheelDurationChanged(let duration):
            return "wheelDurationChanged \(duration)"

        case .wheelStartAndDurationChanged(let startDate, let duration):
            return "wheelStartAndDurationChanged \(startDate) - \(duration)"

        case .billableButtonTapped:
            return "BillableButtonTapped"
            
        case .tagButtonTapped:
            return "TagButtonTapped"

        case .addTagChipTapped:
            return "AddTagChipTapped"
            
        case .projectButtonTapped:
            return "ProjectButtonTapped"

        case .addProjectChipTapped:
            return "AddProjectButtonTapped"
            
        case let .tagCreated(tag):
            return "Tag created: \(tag.name)"
            
        case let .setError(error):
            return "SetError: \(error)"

        case let .autocompleteSuggestionsUpdated(suggestions):
            return "AutocompleteSuggestionsUpdated \(suggestions)"

        case let .durationInputted(duration):
            return ".durationInputted \(duration)"
        }
    }
}
