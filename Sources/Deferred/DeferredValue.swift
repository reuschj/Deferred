//
//  DeferredValue.swift
//  
//
//  Created by Justin Reusch on 6/12/20.
//

/// Property wrapper to store a deferred value as a property
@propertyWrapper
public struct DeferredValue<Type> {
    
    /// Holds the deferred value
    private var deferred: Deferred<Type> = .empty
    
    /**
     Initializer
     - Parameter wrappedValue: The value to set
     */
    public init(wrappedValue: Type?) {
        self.set(wrappedValue)
    }
    
    /// Sets the deferred value
    private mutating func set(_ value: Type? = nil) {
        if let value = value {
            deferred = .resolved(value)
        }
    }
    
    /// Wrapped value
    public var wrappedValue: Type? {
        get { deferred.value }
        set { self.set(newValue) }
    }
    
    /// Value accessed with the $
    public var projectedValue: Deferred<Type> { deferred }
}

extension DeferredValue: Equatable where Type: Equatable {
    
    /// Tests equality
    public static func == (lhs: DeferredValue<Type>, rhs: DeferredValue<Type>) -> Bool {
        lhs.deferred == rhs.deferred
    }
}

extension DeferredValue: Comparable where Type: Comparable {
    
    /// Comparison
    public static func < (lhs: DeferredValue<Type>, rhs: DeferredValue<Type>) -> Bool {
        lhs.deferred < rhs.deferred
    }
}
