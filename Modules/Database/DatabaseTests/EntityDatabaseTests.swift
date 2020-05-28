import XCTest
import Models
import Utils
import CoreData
import Assets
@testable import Database

// swiftlint:disable force_try force_cast
open class EntityDatabaseTests<EntityType: CoreDataModel>: XCTestCase where EntityType: Entity, EntityType: Equatable {

    var initialEntities: [EntityType] { [] }
    var insertedEntities: [EntityType] { [] }
    var updatedEntities: [EntityType] { [] }

    internal var database: Database!
    var entityDatabase: EntityDatabase<EntityType> { fatalError("Override in subclass") }

    private let model = "Database"

    lazy var mockContainer: NSPersistentContainer = {
        let bundle = Assets.bundle
        guard let modelURL = bundle.url(forResource: self.model, withExtension: "momd") else { fatalError() }
        guard let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL) else { fatalError() }

        let container = NSPersistentContainer(name: model, managedObjectModel: managedObjectModel)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in

            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )

            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    open override func setUp() {
        super.setUp()
        initializeData(entities: initialEntities)
        database = Database(persistentContainer: mockContainer)
    }

    open override func tearDown() {
        flushData()
        super.tearDown()
    }

    func testGetAll() {
        let entities = try! entityDatabase.getAll()
        XCTAssert(entities.equalContents(to: initialEntities), "getAll must return all entities")
    }

    func testGetOne() {
        let expectedWorkspace = initialEntities[0]
        let workspace = try! entityDatabase.getOne(id: expectedWorkspace.id)
        XCTAssertEqual(workspace, expectedWorkspace, "getOne must return the correct workspace")
    }

    func testInsertArray() {
        try! entityDatabase.insert(entities: insertedEntities)

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: initialEntities + insertedEntities), "Insert must create the new entities")
    }

    func testInsert() {
        let insertedEntity = insertedEntities.first!

        try! entityDatabase.insert(entity: insertedEntity)

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: initialEntities + [insertedEntity]), "Insert must create the new entity")
    }

    func testUpdateArray() {
        let expected = updatedEntities

        try! entityDatabase.update(entities: expected)

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: expected), "Update must update the items in the DB")
    }

    func testUpdate() {
        let updated = updatedEntities.first!

        try! entityDatabase.update(entity: updated)

        let dbItem = try! mockContainer.items()
            .map(EntityType.from)
            .first(where: { $0.id == updated.id })

        XCTAssertEqual(dbItem, updated, "Update must update the specific item in the DB")
    }

    func testDeleteWithId() {
        let toDelete = initialEntities.first!

        try! entityDatabase.delete(id: toDelete.id)

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: Array(initialEntities.dropFirst())), "Delete must remote the specific item from the DB")
    }

    func testDelete() {
        let toDelete = initialEntities.first!

        try! entityDatabase.delete(entity: toDelete)

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: Array(initialEntities.dropFirst())), "Delete must remote the specific item from the DB")
    }

    // MARK: Private methods

    private func initializeData<T: CoreDataModel>(entities: [T]) {
        for entity in entities {
            insertEntity(entity: entity)
        }

        do {
            try mockContainer.viewContext.save()
        } catch {
            print("create fakes error \(error)")
        }
    }

    private func flushData() {
        let stores = mockContainer.persistentStoreCoordinator.persistentStores
        for store in stores {
            try! mockContainer.persistentStoreCoordinator.remove(store)
        }
    }

    @discardableResult
    internal func insertEntity<T: CoreDataModel>(entity: T) -> T.ManagedObject? {
        let obj = NSEntityDescription.insertNewObject(
            forEntityName: T.ManagedObject.entityName,
            into: mockContainer.viewContext
        ) as! T.ManagedObject

        try! entity.encode(into: obj, context: mockContainer.viewContext)

        return obj
    }

    internal func deleteEntity(object: NSManagedObject) {
        mockContainer.viewContext.delete(object)
        try! mockContainer.viewContext.save()
    }
}
