import Foundation
import RxSwift

extension EntityDatabase: ReactiveCompatible { }

extension Reactive where Base: EntityDatabaseProtocol, Base.EntityType: ReactiveCompatible {

    public func getAll() -> Single<[Base.EntityType]> {
        return Single.create { single in
            let context = self.base.stack.backgroundContext
            context.perform {
                do {
                    let result = try Base.EntityType.get(in: context)
                    single(.success(result))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }

    public func getOne(id: Int64) -> Single<Base.EntityType?> {
        return Single.create { single in
            let context = self.base.stack.backgroundContext
            context.perform {
                do {
                    let result = try Base.EntityType.get(
                        in: context, predicate: NSPredicate(format: "id = %i", id)
                    ).first
                    single(.success(result))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }

    public func insert(entities: [Base.EntityType]) -> Single<Void> {
        return Single.create { single in
            let context = self.base.stack.backgroundContext
            context.perform {
                do {
                    try Base.EntityType.create(models: entities, in: context)
                    try context.save()
                    single(.success(()))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }

    public func insert(entity: Base.EntityType) -> Single<Void> {
        return insert(entities: [entity])
    }

    public func update(entities: [Base.EntityType]) -> Single<Void> {
        return Single.create { single in
            let context = self.base.stack.backgroundContext
            context.perform {
                do {
                    try Base.EntityType.update(
                        update: { entity in entities.first(where: { $0.id == entity.id })! },
                        predicate: NSPredicate(format: "id IN %@", entities.map({ $0.id })),
                        in: context
                    )
                    try context.save()
                    single(.success(()))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }

    public func update(entity: Base.EntityType) -> Single<Void> {
        update(entities: [entity])        
    }

    public func delete(id: Int64) -> Single<Void> {
        return Single.create { single in
            let context = self.base.stack.backgroundContext
            context.perform {
                do {
                    try Base.EntityType.delete(
                        in: context,
                        predicate: NSPredicate(format: "id == %i", id)
                    )
                    try context.save()
                    single(.success(()))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create { }
        }
    }

    public func delete(entity: Base.EntityType) -> Single<Void> {
        delete(id: entity.id)
    }
}
