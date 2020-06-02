import CalendarService
import Foundation
import API
import Repository
import Networking
import OtherServices
import Timer
import Database
import Analytics

public struct AppEnvironment {
    public let api: API
    public let repository: Repository
    public let time: Time
    public let schedulerProvider: SchedulerProvider
    public let analytics: AnalyticsService
    public let calendarService: CalendarService

    public init(
        api: API,
        repository: Repository,
        time: Time,
        schedulerProvider: SchedulerProvider,
        analytics: AnalyticsService,
        calendarService: CalendarService
    ) {
        self.api = api
        self.repository = repository
        self.time = time
        self.schedulerProvider = schedulerProvider
        self.analytics = analytics
        self.calendarService = calendarService
    }

    public init(analyticsServices: [AnalyticsService]) {
        self.api = API(urlSession: FakeURLSession())
//        self.api = API(urlSession: URLSession(configuration: URLSessionConfiguration.default))
        self.time = Time()
        self.repository = Repository(api: api, database: Database(), time: time)
        self.schedulerProvider = SchedulerProvider()
        self.analytics = CompositeAnalyticsService(analyticsServices: analyticsServices)
        self.calendarService = DefaultCalendarService()
    }
}

extension AppEnvironment {
    var userAPI: UserAPI {
        return api
    }
}
