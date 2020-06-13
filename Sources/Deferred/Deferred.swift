//
//  Deferred.swift
//
//
//  Created by Justin Reusch on 6/12/20.
//

/// Placeholder for a value that will we be resolved later by another entity
/// Essentially, it's a wrapper around a value to allow the resolved value to be safely extracted or set.
/// It functions much like an Optional, but communicates to another entity that the responsibility of setting has been deferred to by the passing entity which may not have enough information to set it.
public enum Deferred<Type>: CustomStringConvertible, Hashable, Comparable where Type: Comparable & Hashable {
    case resolved(Type)
    case empty
    
    // Computed properties -------------------------------- /
    
    /// The resolved value, which will be `nil` if unresolved
    public var value: Type? {
        switch self {
        case .resolved(let value):
            return value
        case .empty:
            return nil
        }
    }
    
    /// String representation
    public var description: String {
        guard let value = self.value else { return "" }
        return "\(value)"
    }
    
    // Mapping methods -------------------------------------- /
    
    /**
     Applies a transform callback on the resolved value and returns the result (or `nil` if unresovled)
     - Parameter transform: A callback function to apply to the resolved value
     */
    public func map<ResultType>(_ transform: (Type) -> ResultType) -> ResultType? {
        guard let value = self.value else { return nil }
        return transform(value)
    }
    
    // Comparison and equality -------------------------------------- /
    
    /// Comparison of two deferred values
    public static func < (lhs: Deferred<Type>, rhs: Deferred<Type>) -> Bool {
        guard let leftValue = lhs.value else {
            guard let rightValue = rhs.value else { return true } // both are unresolved
            return true // Resolved value is greater than unresolved
        }
        guard let rightValue = rhs.value else { return false } // Resolved value is less than resolved
        return leftValue < rightValue // Evaluate values
    }
    
    /// Tests equality of two deferred values
    public static func == (lhs: Deferred<Type>, rhs: Deferred<Type>) -> Bool {
        guard let leftValue = lhs.value else {
            guard let rightValue = rhs.value else { return true } // both are unresolved
            return false // Resolved value does not equal an unresolved value
        }
        guard let rightValue = rhs.value else { return false } // Resolved value does not equal an unresolved value
        return leftValue == rightValue // Evaluate values
    }
    
    /// Comparison of a deferred value to a value of it's wrapped type
    public static func < (lhs: Deferred<Type>, rhs: Type) -> Bool {
        guard let leftValue = lhs.value else { return false }
        return leftValue < rhs
    }
    
    /// Comparison of a deferred value to a value of it's wrapped type
    public static func < (lhs: Type, rhs: Deferred<Type>) -> Bool {
        guard let rightValue = rhs.value else { return false }
        return rightValue < lhs
    }
    
    /// Tests equality of a deferred value to a value of it's wrapped type
    public static func == (lhs: Deferred<Type>, rhs: Type) -> Bool {
        guard let leftValue = lhs.value else { return false }
        return leftValue == rhs
    }
    
    /// Tests equality of a deferred value to a value of it's wrapped type
    public static func == (lhs: Type, rhs: Deferred<Type>) -> Bool {
        guard let rightValue = rhs.value else { return false }
        return rightValue == lhs
    }
    
    // Hashable -------------------------------------- /
    
    /// Generates hash value
    public func hash(into hasher: inout Hasher) {
        if let value = self.value {
            hasher.combine(value)
        }
    }
}
