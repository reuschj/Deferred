import XCTest
@testable import Deferred

final class DeferredTests: XCTestCase {
    func testResolvingValue() {
        var foo: Deferred<Double> = .empty
        var bar: Deferred<String> = .empty
        var baz: Deferred<Bool> = .empty
        XCTAssertEqual(foo.value, nil)
        XCTAssertEqual(bar.value, nil)
        XCTAssertEqual(baz.value, nil)
        XCTAssertEqual(foo.isResolved, false)
        XCTAssertEqual(bar.isResolved, false)
        XCTAssertEqual(baz.isResolved, false)
        foo = .resolved(45)
        bar = .resolved("Bar")
        baz = .resolved(true)
        XCTAssertEqual(foo.isResolved, true)
        XCTAssertEqual(bar.isResolved, true)
        XCTAssertEqual(baz.isResolved, true)
        XCTAssertEqual(foo.value!, 45)
        XCTAssertEqual(bar.value!, "Bar")
        XCTAssertEqual(baz.value!, true)
    }
    
    func testDeferredMap() {
        var foo: Deferred<Double> = .empty
        var bar: Deferred<String> = .empty
        var baz: Deferred<Bool> = .empty
        foo = .resolved(45)
        bar = .resolved("Bar")
        baz = .resolved(true)
        XCTAssertEqual(foo.map { $0 * 2 }, 90)
        XCTAssertEqual(bar.map { "Hello, \($0)" }, "Hello, Bar")
        XCTAssertEqual(baz.map { !$0 }, false)
    }
    
    func testEqualityAndComparison() {
        let foo: Deferred<Double> = .resolved(45)
        let foo2: Deferred<Double> = .resolved(45)
        let foo3: Deferred<Double> = .resolved(24)
        let foo4: Deferred<Double> = .resolved(50)
        let bar: Deferred<String> = .resolved("Bar")
        let bar2: Deferred<String> = .resolved("Bar")
        let bar3: Deferred<String> = .resolved("B")
        let bar4: Deferred<String> = .resolved("BarFoo")
        let baz: Deferred<Bool> = .resolved(true)
        let baz2: Deferred<Bool> = .resolved(true)
        let baz3: Deferred<Bool> = .resolved(false)
        XCTAssertEqual(foo, foo2)
        XCTAssertGreaterThanOrEqual(foo, foo2)
        XCTAssertLessThanOrEqual(foo, foo2)
        XCTAssertNotEqual(foo, foo3)
        XCTAssertGreaterThan(foo, foo3)
        XCTAssertNotEqual(foo, foo4)
        XCTAssertLessThan(foo, foo4)
        XCTAssertTrue(foo == 45.0)
        XCTAssertTrue(foo > 20.0)
        XCTAssertTrue(foo >= 20.0)
        XCTAssertTrue(foo < 50.0)
        XCTAssertTrue(foo <= 50.0)
        //
        XCTAssertEqual(bar, bar2)
        XCTAssertNotEqual(bar, bar3)
        XCTAssertGreaterThan(bar, bar3)
        XCTAssertNotEqual(bar, bar4)
        XCTAssertLessThan(bar, bar4)
        //
        XCTAssertEqual(baz, baz2)
        XCTAssertNotEqual(baz, baz3)
    }
    
    func testHashable() {
        let foo: Deferred<String> = .resolved("Foo")
        let foo2: Deferred<String> = .resolved("Foo")
        let bar: Deferred<String> = .resolved("Bar")
        let bar2: Deferred<String> = .resolved("Bar2")
        let baz: Deferred<String> = .resolved("Baz")
        let baz2: Deferred<String> = .empty
        let baz3: Deferred<String> = .empty
        var set = Set<Deferred<String>>()
        set.insert(foo)
        XCTAssertEqual(set.count, 1)
        set.insert(foo2)
        XCTAssertFalse(set.contains(bar))
        XCTAssertEqual(set.count, 1)
        set.insert(bar)
        XCTAssertEqual(set.count, 2)
        set.insert(bar2)
        XCTAssertEqual(set.count, 3)
        set.insert(baz)
        XCTAssertEqual(set.count, 4)
        set.insert(baz2)
        XCTAssertEqual(set.count, 5)
        set.insert(baz3)
        XCTAssertEqual(set.count, 5)
        XCTAssertTrue(set.contains(foo))
        XCTAssertTrue(set.contains(bar))
        XCTAssertTrue(set.contains(bar2))
        XCTAssertTrue(set.contains(baz))
    }
    
    func testReference() {
        let foo: DeferredReference<Double> = DeferredReference()
        XCTAssertEqual(foo.current, .empty)
        XCTAssertFalse(foo.current.isResolved)
        XCTAssertNil(foo.value)
        foo.resolve(45)
        XCTAssertTrue(foo.current.isResolved)
        XCTAssertEqual(foo.value!, 45)
        foo.resolve(50)
        XCTAssertEqual(foo.value!, 50)
        XCTAssertEqual(foo.allResolved.count, 2)
        XCTAssertEqual(foo.values.count, 2)
        foo.resolve(50)
        XCTAssertEqual(foo.value!, 50)
        XCTAssertEqual(foo.allResolved.count, 3)
        XCTAssertEqual(foo.values.count, 2)
        foo.resolve(100)
        XCTAssertEqual(foo.value!, 100)
        XCTAssertEqual(foo.allResolved.count, 4)
        XCTAssertEqual(foo.values.count, 3)
        XCTAssertFalse(foo.finalized)
        foo.finalize()
        XCTAssertEqual(foo.value!, 100)
        XCTAssertTrue(foo.finalized)
        XCTAssertEqual(foo.allResolved.count, 4)
        XCTAssertEqual(foo.values.count, 3)
        let bar: DeferredReference<Double> = DeferredReference(2)
        let baz = bar
        baz.resolve(4)
        XCTAssertEqual(bar.value!, 4)
        XCTAssertEqual(baz.value!, 4)
    }
    
    func testPropertyWrapper() {
        struct Foo {
            @DeferredValue var bar: String? = nil
        }
        var foo = Foo()
        XCTAssertNil(foo.bar)
        foo.bar = "Hello!"
        XCTAssertNotNil(foo.bar)
        XCTAssertEqual(foo.bar!, "Hello!")
        let bar = Foo(bar: "Hello, World!")
        XCTAssertNotNil(bar.bar)
        XCTAssertEqual(bar.bar!, "Hello, World!")
    }

    static var allTests = [
        ("testResolvingValue", testResolvingValue),
        ("testDeferredMap", testDeferredMap),
        ("testEqualityAndComparison", testEqualityAndComparison),
        ("testHashable", testHashable),
        ("testPropertyWrapper", testPropertyWrapper),
        ("testReference", testReference)
    ]
}
