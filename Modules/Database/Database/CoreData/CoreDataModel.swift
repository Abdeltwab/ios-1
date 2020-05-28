import Foundation
import CoreData

public protocol CoreDataModel {
    associatedtype ManagedObject: NSManagedObject, Managed
    static func from(managedObject: ManagedObject) throws -> Self
    func encode(into: ManagedObject, context: NSManagedObjectContext) throws
}

extension CoreDataModel {
    
    static func get(
        in context: NSManagedObjectContext,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [Self] {
        try ManagedObject.fetch(in: context) { request in
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
        }
        .map(from)
    }

    static func create(
        models: [Self],
        in context: NSManagedObjectContext
    ) throws {
        for model in models {
            let managedObject = ManagedObject.insert(into: context)
            try model.encode(into: managedObject, context: context)
        }
    }

    static func update(
        update: (Self) -> Self,
        predicate: NSPredicate,
        in context: NSManagedObjectContext
    ) throws {
        let managedObjects = try ManagedObject.fetch(in: context) { request in
            request.predicate = predicate
        }
        let entities = try managedObjects.map { try from(managedObject: $0) }
        let updatedEntities = entities.map(update)

        for (managedObject, entity) in zip(managedObjects, updatedEntities) {
            try entity.encode(into: managedObject, context: context)
        }
    }

    static func delete(
        in context: NSManagedObjectContext,
        predicate: NSPredicate
    ) throws {
        let managedObjects = try ManagedObject.fetch(in: context) { request in
            request.predicate = predicate
        }
        for managedObject in managedObjects {
            context.delete(managedObject)
        }
    }
}
