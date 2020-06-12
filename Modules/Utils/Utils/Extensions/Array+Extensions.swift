import Foundation

extension Array {
    
    public func grouped<Key: Hashable>(by selectKey: (Element) -> Key) -> [[Element]] {
        var groups = [Key: [Element]]()
        
        for element in self {
            let key = selectKey(element)
            
            if case nil = groups[key]?.append(element) {
                groups[key] = [element]
            }
        }
        
        return groups.map { $0.value }
    }
    
    public func safeGet(_ index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }

    public func appending(_ element: Element) -> [Element] {
        return self + [element]
    }

    public func prepending(_ element: Element) -> [Element] {
        return [element] + self
    }

    public func removingLast() -> [Element] {
        var collection = self
        collection.removeLast()
        return collection
    }

    public func removingFirst() -> [Element] {
        var collection = self
        collection.removeFirst()
        return collection
    }

    public func take(_ firstN: Int) -> [Element] {
        Array(self.prefix(firstN))
    }
}
