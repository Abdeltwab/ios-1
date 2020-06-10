import Foundation
import CoreData
import Models

extension TimeEntry: CoreDataModel {
    public static func from(managedObject: ManagedTimeEntry) throws -> TimeEntry {
        TimeEntry(
            id: managedObject.id,
            description: managedObject.textDescription,
            start: managedObject.start,
            duration: managedObject.duration?.doubleValue,
            billable: managedObject.billable,
            workspaceId: managedObject.workspace.id,
            projectId: managedObject.project?.id,
            tagIds: managedObject.tags.map { $0.id }
        )
    }

    public func encode(into managedObject: ManagedTimeEntry, context: NSManagedObjectContext) throws {
        managedObject.id = self.id
        managedObject.textDescription = self.description
        managedObject.start = self.start
        managedObject.duration = self.duration != nil ? NSNumber(value: self.duration!) : nil
        managedObject.billable = self.billable
        managedObject.workspace = try ManagedWorkspace.findOrFetch(in: context, withId: workspaceId)!
        managedObject.project = self.projectId != nil
            ? try ManagedProject.findOrFetch(in: context, withId: self.projectId!)!
            : nil
        managedObject.tags = Set(try self.tagIds.map { try ManagedTag.findOrFetch(in: context, withId: $0)! })
    }
}
