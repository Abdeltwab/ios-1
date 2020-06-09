import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices
import Analytics
import CalendarService

func createLogSuggestionReducer(
    repository: Repository,
    time: Time,
    calendarService: CalendarService) -> Reducer<LogSuggestionState, LogSuggestionAction> {

    return Reducer {_, _ -> [Effect<LogSuggestionAction>] in

//        switch action {
//
//        case <#value#>:
//            return []
//        }
    }
}
