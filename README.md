# Deferred

A deferred value stands as a placeholder for a value that will we be resolved later by another entity. Essentially, it's a wrapper around a value to allow the resolved value to be safely extracted or set. If there is no value, we are telling the receiver that it'sfree to set it using it's own logic. Once that value is resolved, it can be used or resolved again until finalized.

It's function is much like an `Optional`, but communicates to another entity that the responsibility of setting has been deferred to by the passing entity which may not have enough information to set it.

```swift

struct Box {
    var width: Double
    var height: Double
}

struct AutoFillBox {
    private var _width: Deferred<Double> = .empty
    private var _height: Deferred<Double> = .empty

    var width: Double? {
        switch self._width {
        case .resolved(let width):
            return width
        default:
            return nil 
        }
    }

    var height: Double? {
        switch self._height {
        case .resolved(let height):
            return height
        default:
            return nil 
        }
    }

    mutating func fit(to box: Box) {
        self._width = .resolved(box.width)
        self._height = .resolved(box.height)
    }
}

var autoBox = AutoFillBox()
var box = Box(width: 4, height: 5)
autoBox.fit(to: box)

print(autoBox.width ?? "Not set") // 4.0
print(autoBox.height ?? "Not set") // 5.0

```
In the case above, the height and width of the auto-fill box are not set until there is a `Box` to fit to.

It's a fair point that all of this can be accomplished quite well with ordinary `Optional` values. In face, the design of `Deferred` is similar to that of `Optional`. While functionally the same, `Deferred` communicates that this value is specifically waiting to be set.

The value can be unwrapped with a `switch` statement or with the `value` property, and `Optional` which will return `nil` if not resolved.

## Property Wrapper
If you are using `Deferred` for a property but want to abstract the usage, use the `@DeferredValue` property wrapper:

```swift

struct AutoFillBox {
    @DeferredValue var width: Double = 0
    @DeferredValue var height: Double = 0

    mutating func fit(to box: Box) {
        self.width = box.width
        self.height = box.height
    }
}

var autoBox = AutoFillBox()
var box = Box(width: 4, height: 5)
autoBox.fit(to: box)

print(autoBox.width ?? "Not set") // 4.0
print(autoBox.height ?? "Not set") // 5.0

```

## Deferred Reference
The `Deferred` type is a value type, but if you need it as a reference type, you can use the `DeferredReference` class, which wraps it in a heap-allocated reference type. In addition, it stores previously resolved values and allows finalization.

```swift

let ref1: DeferredReference<String> = DeferredReference()
let ref2: DeferredReference<String> = DeferredReference("Hello!")
ref1.resolve("Hi!")
print(ref1.value ?? "None") // Hi!
print(ref2.value ?? "None") // Hello!
ref2.resolve("Hello!")
ref2.resolve("Hello, World!")
print(ref2.value ?? "None") // Hello, World!
ref1.finalize("Hello, World!")
ref2.finalize()
print(ref1.value ?? "None") // Hello, World!
print(ref2.value ?? "None") // Hello, World!
print(ref2.allResolved) // ["Hello!", "Hello!", "Hello, World!"]
print(ref2.values) // ["Hello, World!", "Hello!"]

```

The reference stores the `Deferred` value in the `current` property and the value can be accessed with the `value` property. Use the `resolve()` method to resolve the value. Each time a value is resolved, it's added to a list of resolved values. That list is accessible with the `allResolved` property. It's also added to a `Set`, accessible with the `values` property. When you want to lock the reference, use the `finalize()` method. You can pass a value to resolve with before finalization or omit to finalize with whatever is currently stored.
