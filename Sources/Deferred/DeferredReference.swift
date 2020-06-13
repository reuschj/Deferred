//
//  DeferredReference.swift
//  
//
//  Created by Justin Reusch on 6/12/20.
//

/// Wraps a deferred value in a reference-type class
/// Holds a current value which can be resolved multiple times or finalized (to lock it)
/// All resolved values are stored in an array and set
public class DeferredReference<Type>: CustomStringConvertible, Hashable, Comparable where Type: Comparable & Hashable {
    
    /// The current deferred value
    public private(set) var current: Deferred<Type> = .empty
    
    /// An array of all values resolved (in order of resolution)
    public private(set) var allResolved: [Type] = []
    
    /// A set of all values resolved (no duplicates)
    public private(set) var values: Set<Type> = Set()
    
    /// When finalized, the current value can no longer be resolved and the stored value is final and immutable
    public private(set) var finalized: Bool = false
    
    // Computed properties -------------------------------- /
    
    /// Gets count of resovled values (including duplicates)
    public var count: Int { self.allResolved.count }
    
    /// Gets the value of the current deferred value (possibly `nil`)
    public var value: Type? { self.current.value }
    
    /// Gets the description of the current deferred value
    public var description: String { self.current.description }
    
    // Initializers -------------------------------------- /
    
    public init(_ value: Type? = nil, finalize: Bool = false) {
        if let value = value {
            self.resolve(value, finalize: finalize)
        } else {
            self.current = .empty
        }
    }
    
    // Methods -------------------------------------- /
    
    /**
     Resolves with a value, replacing any value resolved, if any.
     - Parameter value: Value to resolve with
     - Parameter finalize: If true, finalizes. When finalized, the current value can no longer be resolved and the stored value is final and immutable.
     */
    public func resolve(_ value: Type, finalize: Bool = false) -> Type? {
        if finalized {
            return self.current.value
        }
        self.current = .resolved(value)
        self.allResolved.append(value)
        self.values.insert(value)
        if finalize {
            self.finalized = true
        }
        return value
    }
    
    /**
     When finalized, the current value can no longer be resolved and the stored value is final and immutable.
     Pass a value to resolve the final value first. Pass `nil` or omit a value to finalize with the last resolved value.
     - Parameter value: Value to resolve and finalize with. If omitted or `nil`, finalizes the last resolved value.
     */
    public func finalize(_ value: Type? = nil) -> Type? {
        guard let value = value else {
            self.finalized = true
            return self.current.value
        }
        return self.resolve(value, finalize: true)
    }
    
    // Mapping methods -------------------------------------- /
    
    /**
     Applies a transform callback on the resolved value and returns the result (or `nil` if unresovled)
     - Parameter transform: A callback function to apply to the resolved value
     */
    public func map<ResultType>(_ transform: (Type) -> ResultType) -> ResultType? {
        return self.current.map(transform)
    }
    
    /**
     Applies a transform callback on all resolved values in order of resolution and returns the results in an array
     - Parameter transform: A callback function to apply to the resolved value
     */
    public func mapAllResolved<ResultType>(_ transform: (Type) -> ResultType) -> [ResultType]? {
        return self.allResolved.map(transform)
    }
    
    /**
     Applies a transform callback on all values resolved (no duplicates) and returns the results in an array
     - Parameter transform: A callback function to apply to the resolved value
     */
    public func mapValues<ResultType>(_ transform: (Type) -> ResultType) -> [ResultType]? {
        return self.values.map(transform)
    }
    
    // Comparison and equality -------------------------------------- /
    
    /// Comparison of two deferred values
    public static func < (lhs: DeferredReference<Type>, rhs: DeferredReference<Type>) -> Bool {
        return lhs.current < rhs.current
    }
    
    /// Tests equality of two deferred values
    public static func == (lhs: DeferredReference<Type>, rhs: DeferredReference<Type>) -> Bool {
        return lhs.current == rhs.current
    }
    
    /// Comparison of a deferred value to a value of it's wrapped type
    public static func < (lhs: DeferredReference<Type>, rhs: Type) -> Bool {
        return lhs.current < rhs
    }
    
    /// Comparison of a deferred value to a value of it's wrapped type
    public static func < (lhs: Type, rhs: DeferredReference<Type>) -> Bool {
        return lhs < rhs.current
    }
    
    /// Tests equality of a deferred value to a value of it's wrapped type
    public static func == (lhs: DeferredReference<Type>, rhs: Type) -> Bool {
        return lhs.current == rhs
    }
    
    /// Tests equality of a deferred value to a value of it's wrapped type
    public static func == (lhs: Type, rhs: DeferredReference<Type>) -> Bool {
        return lhs == rhs.current
    }
    
    // Hashable -------------------------------------- /
    
    /// Generates hash value
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.count)
        self.allResolved.map { hasher.combine($0) }
    }
}
