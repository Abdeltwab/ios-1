import XCTest
import Models
import Utils
import CoreData
import Assets
import RxSwift
import RxBlocking
import RxTest
@testable import Database

// swiftlint:disable force_try
open class EntityDatabaseRxExtensionsTests<EntityType: CoreDataModel>: EntityDatabaseTests<EntityType>
where EntityType: Entity, EntityType: Equatable, EntityType: ReactiveCompatible {

    func testRxGetAll() {
        let entities = try! entityDatabase.rx.getAll().toBlocking().first()!
        XCTAssert(entities.equalContents(to: initialEntities), "getAll must return all entities")
    }

    func testRxGetOne() {
        let expectedWorkspace = initialEntities[0]
        let workspace = try! entityDatabase.rx.getOne(id: expectedWorkspace.id).toBlocking().first()!
        XCTAssertEqual(workspace, expectedWorkspace, "getOne must return the correct workspace")
    }

    func testRxInsertArray() {
        _ = try! entityDatabase.rx.insert(entities: insertedEntities).toBlocking().toArray()

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: initialEntities + insertedEntities), "Insert must create the new entities")
    }

    func testRxInsert() {
        let insertedEntity = insertedEntities.first!

        _ = try! entityDatabase.rx.insert(entity: insertedEntity).toBlocking().toArray()

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: initialEntities + [insertedEntity]), "Insert must create the new entity")
    }

    func testRxUpdateArray() {
        let expected = updatedEntities

        _ = try! entityDatabase.rx.update(entities: expected).toBlocking().toArray()

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: expected), "Update must update the items in the DB")
    }

    func testRxUpdate() {
        let updated = updatedEntities.first!

        _ = try! entityDatabase.rx.update(entity: updated).toBlocking().toArray()

        let dbItem = try! mockContainer.items()
            .map(EntityType.from)
            .first(where: { $0.id == updated.id })

        XCTAssertEqual(dbItem, updated, "Update must update the specific item in the DB")
    }

    func testRxDeleteWithId() {
        let toDelete = initialEntities.first!

        _ = try! entityDatabase.rx.delete(id: toDelete.id).toBlocking().toArray()

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: Array(initialEntities.dropFirst())), "Delete must remote the specific item from the DB")
    }

    func testRxDelete() {
        let toDelete = initialEntities.first!

        _ = try! entityDatabase.rx.delete(entity: toDelete).toBlocking().toArray()

        let dbItems = try! mockContainer.items().map(EntityType.from)

        XCTAssert(dbItems.equalContents(to: Array(initialEntities.dropFirst())), "Delete must remote the specific item from the DB")
    }
}
