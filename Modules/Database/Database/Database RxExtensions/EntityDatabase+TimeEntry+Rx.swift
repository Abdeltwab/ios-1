import Foundation
import Models
import RxSwift

extension Reactive where Base: EntityDatabaseProtocol, Base.EntityType == TimeEntry {

    public func getAllSortedBackground() -> Single<[TimeEntry]> {
        return Single.create { single in
            self.base.stack.persistentContainer.performBackgroundTask { context in
                do {
                    let result = try TimeEntry.get(
                        in: context,
                        sortDescriptors: [NSSortDescriptor(key: "start", ascending: false)]
                    )
                    single(.success(result))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }

    public func getAllRunningBackground() -> Single<[TimeEntry]> {
        return Single.create { single in
            self.base.stack.persistentContainer.performBackgroundTask { context in
                do {
                    let result = try TimeEntry.get(
                        in: context,
                        predicate: NSPredicate(format: "duration == nil"),
                        sortDescriptors: [NSSortDescriptor(key: "start", ascending: false)]
                    )
                    single(.success(result))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }
}
