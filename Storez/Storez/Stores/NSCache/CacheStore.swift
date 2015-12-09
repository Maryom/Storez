//
//  CacheStore.swift
//  Storez
//
//  Created by Mazyad Alabduljaleel on 12/8/15.
//  Copyright © 2015 mazy. All rights reserved.
//

import Foundation


public final class CacheStore: Store {
    
    public typealias SerializableType = CacheSupportedType
    
    public let cache = NSCache()
    
    public init() {}
    
    public func clear() {
        cache.removeAllObjects()
    }
    
    private func _get<V: SerializableType>(key: String) -> V? {
        return cache.objectForKey(key) as? V
    }
    
    private func _set<E: EntryType>(entry: E, value: SerializableType?) {
        
        if let value = value {
            cache.setObject(value, forKey: entry.key)
        }
        else {
            cache.removeObjectForKey(entry.key)
        }
        
        E.GroupType.postCommitHook()
    }
    
    public func get<E: EntryType where E.ValueType: SerializableType>(entry: E) -> E.ValueType {
        return _get(entry.key) ?? entry.defaultValue
    }
    
    public func get<E: EntryType, V: SerializableType where E.ValueType == V?>(entry: E) -> V? {
        return _get(entry.key) ?? entry.defaultValue
    }
    
    private func _get<V: CacheConvertible>(key: String) -> V? {
        
        let storedValue: V.CacheType? = _get(key)
        var resultValue: V? = nil
        
        if let storedValue = storedValue {
            resultValue = V.decode(cacheValue: storedValue)
        }
        
        return resultValue
    }
    
    public func get<E: EntryType where E.ValueType: CacheConvertible>(entry: E) -> E.ValueType {
        return _get(entry.key) ?? entry.defaultValue
    }
    
    public func get<E: EntryType, V: CacheConvertible where E.ValueType == V?>(entry: E) -> V? {
        return _get(entry.key) ?? entry.defaultValue
    }
    
    public func set<E: EntryType where E.ValueType: SerializableType>(entry: E, value: E.ValueType) {
        
        let newValue = entry.willChange(value)
        _set(entry, value: newValue)
    }
    
    public func set<E: EntryType, V: SerializableType where E.ValueType == V?>(entry: E, value: V?) {
        
        let newValue = entry.willChange(value)
        _set(entry, value: newValue)
    }
    
    public func set<E: EntryType where E.ValueType: CacheConvertible>(entry: E, value: E.ValueType) {
        
        let newValue = entry.willChange(value)
        _set(entry, value: newValue.encodeForCache)
    }
    
    public func set<E: EntryType, V: CacheConvertible where E.ValueType == V?>(entry: E, value: V?) {
        
        let newValue = entry.willChange(value)
        _set(entry, value: newValue?.encodeForCache)
    }
}
