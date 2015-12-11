//
//  UserDefaultsConvertible.swift
//  Storez
//
//  Created by Mazyad Alabduljaleel on 11/18/15.
//  Copyright © 2015 mazy. All rights reserved.
//

import Foundation

/** See ConvertibleValue for more information
*/
public protocol UserDefaultsConvertible {
    typealias UserDefaultsType: UserDefaultsSupportedType

    static func decode(userDefaultsValue value: UserDefaultsType) -> Self?
    var encodeForUserDefaults: UserDefaultsType? { get }
}


struct UserDefaultsConvertibleBox <T: UserDefaultsConvertible>: UserDefaultsAcceptedType {
    
    let value: T
    
    var supportedType: NSData? {
        return value.encodeForUserDefaults?.encode
    }
    
    init?(storedValue: NSData?) {
        
        guard let storedValue: T.UserDefaultsType = storedValue?.decode(),
            let value = T.decode(userDefaultsValue: storedValue)
            else
        {
            return nil
        }
        
        self.value = value
    }
    
    init(_ value: T) {
        self.value = value
    }
}


struct UserDefaultsNullableConvertibleBox <T: Nullable where T.UnderlyingType: UserDefaultsConvertible>: UserDefaultsAcceptedType {
    
    let value: T
    
    var supportedType: NSData? {
        return value.wrappedValue?.encodeForUserDefaults?.encode
    }
    
    init?(storedValue: NSData?) {
        
        guard let data = storedValue,
            let userDefaultValue: T.UnderlyingType.UserDefaultsType = data.decode(),
            let value = T.UnderlyingType.decode(userDefaultsValue: userDefaultValue)
            else {
            return nil
        }
        
        self.value = T(value)
    }
    
    init(_ value: T) {
        self.value = value
    }
}
