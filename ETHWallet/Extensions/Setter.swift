import Foundation

public protocol SetterProtocol {}

extension SetterProtocol {
    public func set<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = value
        return newSelf
    }

    public func set<Value>(_ keyPath: WritableKeyPath<Self, Value?>, _ value: Value?) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = value
        return newSelf
    }
}
