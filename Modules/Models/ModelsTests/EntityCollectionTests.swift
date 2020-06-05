import XCTest
@testable import Models

private struct TestEntity: Entity, Equatable {
    public var id: Int64
    public var name: String
}

class EntityCollectionTests: XCTestCase {

    func test_entityStoreInitialiser_createsEntityCollectionWithTheRightOrder() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        let entityStore = EntityCollection(entities)
        assert(entityStore.entities == entities)
        assert(entityStore.ids == [0, 1, 2, 3])
    }

    func test_entityStoreEqualityComparison_worksForTwoStoresWithTheSameContents() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        let entityStore1 = EntityCollection(entities)
        let entityStore2 = EntityCollection(entities)
        assert(entityStore1 == entityStore2)
    }

    func test_entityStoreSubscript_returnsCorrectEntity() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        let entityStore = EntityCollection(entities)
        assert(entityStore[2] == entities[2])
    }

    func test_entityStoreIdSubscript_returnsCorrectEntity() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        let entityStore = EntityCollection(entities)
        assert(entityStore[id: 2]?.id == 2)
        assert(entityStore[id: 4] == nil)
    }
    
    func test_entityStoreIdSubscript_whenIdDoesNotMatchIndex_returnsCorrectEntity() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0 + 4, name: "Entity \($0)") }
        let entityStore = EntityCollection(entities)
        assert(entityStore[id: 6]?.id == 6)
        assert(entityStore[2].id == 6)
        assert(entityStore[id: 0] == nil)
    }

    func test_entityStoreIdSubscript_allowsMutation() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        var entityStore = EntityCollection(entities)
        entityStore[id: 2]?.name = "Testing!"
        assert(entityStore[id: 2]?.name == "Testing!")
    }

    func test_entityStoreIdSubscript_allowsEntityReassignment() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        var entityStore = EntityCollection(entities)
        entityStore[id: 2] = TestEntity(id: 5, name: "Testing!")
        assert(entityStore[id: 2]?.name == "Testing!")
        assert(entityStore[id: 2]?.id == 5) // we shouldn't do this normally, but Dictionary<Int64, Entity> allows that as well
    }

    func test_entityStoreFilter_keepsArrayOrder() {
        let entities = [0, 1, 2, 3].map { TestEntity(id: $0, name: "Entity \($0)") }
        let entityStore = EntityCollection(entities)
        assert(entityStore.filter { $0.id < 2 } == Array(entities[0...1]))
    }
}
