import Foundation

public struct EntityCollection<EntityType>: MutableCollection, RandomAccessCollection where EntityType: Entity {

    /// A raw array of each entity's identifier.
    public private(set) var ids: [Int64]

    /// A raw array of the underlying entities.
    public var entities: [EntityType] { Array(self) }

    // The underlying dict to fetch entities
    private var dictionary: [Int64: EntityType]

    /// Initializes an entity store with an array of entities
    ///
    /// - Parameters:
    ///   - elements: An array of entities.
    public init(_ elements: [EntityType]) {
        let idsAndElements = elements.map { (id: $0.id, element: $0) }
        self.ids = idsAndElements.map { $0.id }
        self.dictionary = Dictionary(idsAndElements, uniquingKeysWith: { $1 })
    }

    public var startIndex: Int { self.ids.startIndex }
    public var endIndex: Int { self.ids.endIndex }

    public func index(after index: Int) -> Int {
        self.ids.index(after: index)
    }

    public func index(before index: Int) -> Int {
        self.ids.index(before: index)
    }

    // swiftlint:disable implicit_getter
    public subscript(position: Int) -> EntityType {
        get { self.dictionary[self.ids[position]]! }
        _modify { yield &self.dictionary[self.ids[position]]! }
    }
    // swiftlint:enable implicit_getter

    #if DEBUG
        /// Direct access to an entity by its id.
        ///
        /// - Parameter id: The id of entity to access. Must be a valid id for an
        ///   element of the array and will _not_ insert elements that are not already in the array, or
        ///   remove elements when passed `nil`. Use `append` or `insert(_:at:)` to insert elements. Use
        ///   `remove(id:)` to remove an element by its identifier.
        /// - Returns: The entity.
        public subscript(id id: Int64) -> EntityType? {
            get { self.dictionary[id] }
            set {
                if newValue != nil && self.dictionary[id] == nil {
                    fatalError(
                        """
                        Can't update entity with id \(id) because no such entity exists in the array.
                        If you are trying to insert an entity into the array, use the "append" or "insert" \
                        methods.
                        """
                    )
                }
                if newValue == nil {
                    fatalError(
                        """
                        Can't update entity with id \(id) with nil.
                        If you are trying to remove an entity from the array, use the "remove(id:) method."
                        """
                    )
                }
                self.dictionary[id] = newValue
            }
        }
    #else
        // swiftlint:disable implicit_getter
        public subscript(id id: Int64) -> EntityType? {
            get { self.dictionary[id] }
            _modify { yield &self.dictionary[id] }
        }
        // swiftlint:enable implicit_getter
    #endif

    public mutating func insert(_ entity: EntityType, at index: Int) {
        let id = entity.id
        self.dictionary[id] = entity
        self.ids.insert(id, at: index)
    }

    public mutating func insert(contentsOf entities: [EntityType], at index: Int) {
        for entity in entities.reversed() {
            self.insert(entity, at: index)
        }
    }

    public mutating func append(_ entity: EntityType) {
        let id = entity.id
        self.dictionary[id] = entity
        self.ids.insert(id, at: self.endIndex)
    }

    public mutating func append(contentsOf entities: [EntityType]) {
        for entity in entities.reversed() {
            self.append(entity)
        }
    }

    /// Removes and returns the entity with the specified id.
    ///
    /// - Parameter id: The id of the entity to remove.
    /// - Returns: The removed entity.
    @discardableResult
    public mutating func remove(id: Int64) -> EntityType {
        let entity = self.dictionary[id]
        assert(entity != nil, "Unexpectedly found nil while removing an identified entity.")
        self.dictionary[id] = nil
        self.ids.removeAll(where: { $0 == id })
        return entity!
    }

    @discardableResult
    public mutating func remove(at position: Int) -> EntityType {
        self.remove(id: self.ids.remove(at: position))
    }

    public mutating func removeAll(where shouldBeRemoved: (EntityType) throws -> Bool) rethrows {
        var ids: [Int64] = []
        for (index, id) in zip(self.ids.indices, self.ids).reversed() {
            if try shouldBeRemoved(self.dictionary[id]!) {
                self.ids.remove(at: index)
                ids.append(id)
            }
        }
        for id in ids where !self.ids.contains(id) {
            self.dictionary[id] = nil
        }
    }
}

extension EntityCollection: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.entities.debugDescription
    }
}

extension EntityCollection: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(reflecting: self.entities)
    }
}

extension EntityCollection: CustomStringConvertible {
    public var description: String {
        self.entities.description
    }
}

extension EntityCollection: Equatable where EntityType: Equatable {
    public static func == (lhs: EntityCollection, rhs: EntityCollection) -> Bool {
        lhs.ids == rhs.ids && lhs.dictionary == rhs.dictionary
    }
}
