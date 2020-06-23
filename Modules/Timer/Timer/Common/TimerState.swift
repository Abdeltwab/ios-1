import Foundation
import Models
import Utils
import CalendarService

public struct LocalTimerState: Equatable {
    internal var expandedGroups: Set<Int> = Set<Int>()
    internal var entriesPendingDeletion = Set<Int64>()
    internal var autocompleteSuggestions: [AutocompleteSuggestion] = []
    internal var dateTimePickMode: DateTimePickMode = .none
    internal var cursorPosition: Int = 0
    internal var logSuggestions: [LogSuggestion] = []
    
    public init() {
    }
}

public struct TimerState: Equatable {
    public var user: Loadable<User>
    public var entities: TimeLogEntities
    public var localTimerState: LocalTimerState
    public var editableTimeEntry: EditableTimeEntry?
    public var calendarEvents: [String: CalendarEvent]

    public init(user: Loadable<User>,
                entities: TimeLogEntities,
                editableTimeEntry: EditableTimeEntry?,
                localTimerState: LocalTimerState,
                calendarEvents: [String: CalendarEvent]) {
        self.user = user
        self.entities = entities
        self.localTimerState = localTimerState
        self.editableTimeEntry = editableTimeEntry
        self.calendarEvents = calendarEvents
    }
}

extension TimerState {
    public func isEditingGroup() -> Bool {
        guard let numberOfEntriesBeingEdited = editableTimeEntry?.ids.count else { return false }
        return numberOfEntriesBeingEdited > 1
    }
}

extension TimerState {
    
    internal var timeLogState: TimeEntriesLogState {
        get {
            TimeEntriesLogState(
                logSuggestions: localTimerState.logSuggestions,
                entities: entities,
                expandedGroups: localTimerState.expandedGroups,
                editableTimeEntry: editableTimeEntry,
                entriesPendingDeletion: localTimerState.entriesPendingDeletion
            )
        }
        set {
            entities = newValue.entities
            localTimerState.expandedGroups = newValue.expandedGroups
            editableTimeEntry = newValue.editableTimeEntry
            localTimerState.entriesPendingDeletion = newValue.entriesPendingDeletion
        }
    }
    
    internal var startEditState: StartEditState {
        get {
            StartEditState(
                user: user,
                entities: entities,
                editableTimeEntry: editableTimeEntry,
                autocompleteSuggestions: localTimerState.autocompleteSuggestions,
                dateTimePickMode: localTimerState.dateTimePickMode,
                cursorPosition: localTimerState.cursorPosition
            )
        }
        set {
            user = newValue.user
            entities = newValue.entities
            editableTimeEntry = newValue.editableTimeEntry
            localTimerState.autocompleteSuggestions = newValue.autocompleteSuggestions
            localTimerState.dateTimePickMode = newValue.dateTimePickMode
            localTimerState.cursorPosition = newValue.cursorPosition
        }
    }

    internal var runningTimeEntryState: RunningTimeEntryState {
        get {
            RunningTimeEntryState(
                user: user,
                entities: entities,
                editableTimeEntry: editableTimeEntry
            )
        }
        set {
            user = newValue.user
            entities = newValue.entities
            editableTimeEntry = newValue.editableTimeEntry
        }
    }
    
    internal var projectState: ProjectState {
        get {
            ProjectState(
                editableProject: editableTimeEntry?.editableProject,
                projects: entities.projects
            )
        }
        set {
            entities.projects = newValue.projects
            guard var timeEntry = editableTimeEntry else { return }
            timeEntry.editableProject = newValue.editableProject
            editableTimeEntry = timeEntry
        }
    }

    internal var logSuggestionsState: LogSuggestionState {
        get {
            LogSuggestionState(
                logSuggestions: localTimerState.logSuggestions,
                entities: entities,
                calendarEvents: calendarEvents,
                user: user
            )
        }
        set {
            localTimerState.logSuggestions = newValue.logSuggestions
            entities = newValue.entities
            calendarEvents = newValue.calendarEvents
            user = newValue.user
        }
    }
}
