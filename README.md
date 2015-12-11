
# Storez :floppy_disk:

![Version](https://img.shields.io/badge/version-prerelease-orange.svg)
[![Travis CI](https://travis-ci.org/SwiftKitz/Storez.svg?branch=master)](https://travis-ci.org/SwiftKitz/Storez)
![Swift](https://img.shields.io/badge/swift-2.1-blue.svg)
![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20watchos%20%7C%20tvos-lightgrey.svg)

Safe, statically-typed, store-agnostic key-value storage!

_Even though I shipped it with my app, I still need to invest the time to set this up, and finalize the API. Contributors welcome!_

## Highlights

+ __Fully Customizable:__<br />
Customize the persistence store, the `KeyType` class, post-commit actions .. Make this framework yours!

+ __Batteries Included__:<br />
In case you just want to use stuff, the framework is shipped with pre-configured basic set of classes that you can just use.

+ __Portability, Check!:__<br />
If you're looking to share code between you app and extensions, watchkit, apple watch, you're covered! You can use the `NSUserDefaults` store, just set your shared container identifier as the suite name.

## Features

__Available Stores__

| Store | Backend |
|-------|---------|
| `UserDefaultsStore` | `NSUserDefaults` |
| `CacheStore` | `NSCache` |
|--------------|-----------|

__Type-safe, store-agnostic, nestable Key definitions__

```swift
// Entries must belong to a "group", for namespacing
struct Animals: Group {
    static let id = "animals"
}

let kingdom = Key<Animals, Void?>(id: "mammals", defaultValue: nil)
kingdom.key // "animals:mammals"

// Nesting
struct Cats: Group {
    typealias parent = Animals
    static let id = "cats"
    
    // Groups also have pre and post commit hooks
    func preCommitHook() { /* custom code */ }
    func postCommitHook() { /* custom code */ }
}

let cat = Key<Cats, Void?>(id: "lion", defaultValue: nil)
cat.key     // "animals:cats:lion"
```

__Initialize the store you want__

```swift
// Use UserDefaultsStore for this example
let store = UserDefaultsStore(suite: "io.kitz.testing")
let entry = Key<GlobalGroup, Int?>(id: "entry", defaultValue: nil)

// With three simple functions
store.set(entry, value: 8)
store.get(entry) // 8
store.clear() // Start fresh every time for testing
```

__Optionality is honored throughout__

```swift
let nullable = Key<GlobalGroup, String?>(id: "nullable", defaultValue: nil)
store.get(nullable)?.isEmpty   // nil
store.set(nullable, value: "")
store.get(nullable)?.isEmpty   // true

let nonnull = Key<GlobalGroup, String>(id: "nonnull", defaultValue: "!")
store.get(nonnull).isEmpty  // false
store.set(nonnull, value: "")
store.get(nonnull).isEmpty  // true
```

__Custom objects easily supported__

```swift
struct CustomObject {
    var strings: [String]
}

// You can guarentee they work for a specific store implementation by
// conforming to the store convertible protocol. In this case,
// NSUserDefaults requires the custom object can be converted to and 
// from a supported Underlying type. (see UserDefaultsValueTypes.swift)
extension CustomObject: UserDefaultsConvertible {
    
    // We want to serialize this struct as NSString
    static func decode(userDefaultsValue value: NSString) -> CustomObject? {
        return self.init(strings: value.componentsSeparatedByString(";"))
    }
    
    var encodeForUserDefaults: NSString? {
        return strings.joinWithSeparator(";")
    }
}

// custom objects properly serialized/deserialized
let customObject = CustomObject(
    strings: ["fill", "in", "the"]
)

// let's add a processing block this time
let CustomValue = Key<GlobalGroup, CustomObject?>(id: "custom", defaultValue: nil) {
    
    var processedValue = $0
    processedValue?.strings.append("blank!")
    return processedValue
}

store.set(CustomValue, value: customObject)
store.get(CustomValue)?.strings.joinWithSeparator(" ") // fill in the blank!
```

__Make your own `KeyType`__

```swift
// For example, make an entry that emits NSNotifications
struct MyKey<G: Group, V>: KeyType {
    
    typealias GroupType = G
    typealias ValueType = V
    
    var key: String
    var defaultValue: ValueType
    
    func didChange(oldValue: ValueType, newValue: ValueType) {
        NSNotificationCenter.defaultCenter().postNotificationName(key, object: nil)
    }
}
```

## Getting Started

1. ... Cocoapods, Carthage, and better instructions coming soon.

## Motivation

I've seen a lot of great attempts at statically-types data stores, but they all build a tightly coupled design that limits the end-developer's freedom. With this framework, you can start prototyping right away with the shipped features, then replace the persistence store and `KeyType` functionality with your heart's content __and__ keep your code the way it is!

## Author

Mazyod ([@Mazyod](http://twitter.com/mazyod))

## License

Storez is released under the MIT license. See LICENSE for details.
