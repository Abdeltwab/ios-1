import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices
import Utils

// swiftlint:disable cyclomatic_complexity function_body_length
func createStartEditReducer(repository: TimeLogRepository, time: Time) -> Reducer<StartEditState, StartEditAction> {
    return Reducer {state, action in
        
        switch action {
            
        case let .descriptionEntered(description, position):
            if state.editableTimeEntry != nil {
                state.cursorPosition = position
                state.editableTimeEntry!.description = description
                return updateAutocompleteSuggestionsEffect(description, position, state.entities)
            }
            return []

        case .closeButtonTapped, .dialogDismissed:
            state.editableTimeEntry = nil
            return []

        case .doneButtonTapped:
            return doneButtonTapped(state, repository)

        case .stopButtonTapped:
            guard var editableTimeEntry = state.editableTimeEntry else {
                fatalError("Trying to stop time entry when not editing a time entry")
            }
            
            guard let startTime = editableTimeEntry.start else {
                editableTimeEntry.start = time.now()
                editableTimeEntry.duration = 0
                state.editableTimeEntry = editableTimeEntry
                return []
            }
            
            if editableTimeEntry.duration == nil {
                let maxDuration = TimeInterval.maximumTimeEntryDuration
                let duration = time.now().timeIntervalSince(startTime)
                if duration > 0 && duration <= maxDuration {
                    editableTimeEntry.duration = duration
                    state.editableTimeEntry = editableTimeEntry
                }
                return []
            }
            
            return [Single.just(StartEditAction.pickerTapped(.end)).toEffect()]

        case let .timeEntryStarted(startedTimeEntry, stoppedTimeEntry):
            timeEntryStarted(&state, startedTimeEntry, stoppedTimeEntry)
            return []

        case let .timeEntryUpdated(timeEntry):
            state.entities.timeEntries[timeEntry.id] = timeEntry
            state.editableTimeEntry = nil
            return []
            
        case let .autocompleteSuggestionTapped(suggestion):
            guard state.editableTimeEntry != nil else { fatalError() }

            state.editableTimeEntry?.setDetails(from: suggestion, and: state.cursorPosition)
            return []
            
        case let .dateTimePicked(date):
            dateTimePicked(&state, date: date)
            return []

        case let .pickerTapped(mode):
            state.dateTimePickMode = mode
            return []

        case .dateTimePickingCancelled:
            state.dateTimePickMode = .none
            return []

        case .wheelStartTimeChanged(let startDate):
            state.editableTimeEntry?.start = startDate
            return []

        case .wheelDurationChanged(let duration):
            guard duration >= 0 && duration < .maxTimeEntryDuration else { return [] }
            state.editableTimeEntry?.duration = duration
            return []

        case .wheelStartAndDurationChanged(let startDate, let duration):
            guard duration >= 0 && duration < .maxTimeEntryDuration else { return [] }
            state.editableTimeEntry?.start = startDate
            state.editableTimeEntry?.duration = duration
            return []

        case .billableButtonTapped:
            guard let editableTimeEntry = state.editableTimeEntry else { return [] }
            state.editableTimeEntry?.billable = !editableTimeEntry.billable
            return []

        case let .autocompleteSuggestionsUpdated(suggestions):
            state.autocompleteSuggestions = suggestions
            return []
            
        case .projectButtonTapped, .addProjectChipTapped:
            guard let editableTimeEntry = state.editableTimeEntry else { return [] }
            state.editableTimeEntry?.description = appendCharacter(String(projectToken), toString: editableTimeEntry.description)
            return []
            
        case .tagButtonTapped, .addTagChipTapped:
            guard let editableTimeEntry = state.editableTimeEntry else { return [] }
            state.editableTimeEntry?.description = appendCharacter(String(tagToken), toString: editableTimeEntry.description)
            return []
            
        case let .tagCreated(tag):
            state.entities.tags[tag.id] = tag
            guard state.editableTimeEntry != nil else { fatalError() }
            state.editableTimeEntry!.tagIds.append(tag.id)
            return []

        case let .durationInputted(duration):
            guard duration >= 0,
                let editableTimeEntry = state.editableTimeEntry,
                !editableTimeEntry.isGroup
                else { return[] }
            if editableTimeEntry.isRunningOrNew {
                let newStartTime = time.now() - duration
                state.editableTimeEntry!.start = newStartTime
            } else {
                state.editableTimeEntry!.duration = duration
            }
            return []
        case let .setError(error):
            fatalError(error.description)
        }
    }
}

func timeEntryStarted(_ state: inout StartEditState, _ startedTimeEntry: TimeEntry, _ stoppedTimeEntry: TimeEntry?) {
    state.editableTimeEntry = nil
    state.entities.timeEntries[startedTimeEntry.id] = startedTimeEntry
    if let stoppedTimeEntry = stoppedTimeEntry {
        state.entities.timeEntries[stoppedTimeEntry.id] = stoppedTimeEntry
    }
}

func startTimeEntry(_ timeEntry: StartTimeEntryDto, repository: TimeLogRepository) -> Effect<StartEditAction> {
    return repository
        .startTimeEntry(timeEntry)
        .toEffect(map: StartEditAction.timeEntryStarted ,
                  catch: { error in StartEditAction.setError(error.toErrorType()) })
}

func doneButtonTapped(_ state: StartEditState, _ repository: TimeLogRepository) -> [Effect<StartEditAction>] {
    let editableTimeEntry = state.editableTimeEntry!
    let shouldStartNewTimeEntry = editableTimeEntry.ids.isEmpty
    if shouldStartNewTimeEntry {
        return [startTimeEntry(editableTimeEntry.toStartTimeEntryDto(), repository: repository)]
    }

    let updatedTimeEnries = editableTimeEntry.ids
        .map { state.entities.getTimeEntry($0) }
        .filter { $0 != nil }
        .map { $0!.with(
            description: editableTimeEntry.description,
            billable: editableTimeEntry.billable) }

    persistUpdatedTimeEntries(updatedTimeEnries)
    return []
}

func dateTimePicked(_ state: inout StartEditState, date: Date) {
    if state.editableTimeEntry == nil {
        fatalError("Trying to set time entry date when not editing a time entry")
    }
    if state.dateTimePickMode == .start {
        state.editableTimeEntry!.start = date
    } else if state.dateTimePickMode == .end && state.editableTimeEntry!.start != nil {
        state.editableTimeEntry!.duration = date.timeIntervalSince(state.editableTimeEntry!.start!)
    }
}

func persistUpdatedTimeEntries(_ timeEntries: [TimeEntry]) {
    //repository.update()
}

func appendCharacter( _ character: String, toString string: String) -> String {
    var stringToAppend = character
    if let lastChar = string.last, lastChar != " " {
        stringToAppend = " " + stringToAppend
    }
    return string + stringToAppend
}

extension EditableTimeEntry {
    mutating func setDetails(from suggestion: AutocompleteSuggestion, and cursorPosition: Int) {
        switch suggestion {
        case .timeEntrySuggestion(let timeEntry):
            workspaceId = timeEntry.workspaceId
            description = timeEntry.description
            projectId = timeEntry.projectId
            tagIds = timeEntry.tagIds
            taskId = timeEntry.taskId
            billable = timeEntry.billable
 
        case .projectSuggestion(let project):
            projectId = project.id
            workspaceId = project.workspaceId
            removeQueryFromDescription(projectToken, cursorPosition)

        case .taskSuggestion(let task, let project):
            taskId = task.id
            projectId = project.id
            workspaceId = project.workspaceId
            removeQueryFromDescription(projectToken, cursorPosition)
            
        case .tagSuggestion(let tag):
            guard tag.workspaceId == workspaceId else { return }
            tagIds.append(tag.id)
            removeQueryFromDescription(tagToken, cursorPosition)
            
        case .createProjectSuggestion:
            fatalError()
        case .createTagSuggestion:
            fatalError()
        }
    }
    
    mutating func removeQueryFromDescription(_ token: Character, _ cursorPosition: Int) {
        let (optionalToken, currentQuery) = description.findTokenAndQueryMatchesForAutocomplete(token, cursorPosition)
        guard let token = optionalToken else { return }
        let delimiter = "\(String(token))\(currentQuery)"
        guard let rangeToReplace = description.range(of: delimiter) else { return }
        let newDescription = description.replacingCharacters(in: rangeToReplace, with: "")
        description = newDescription
    }
}
