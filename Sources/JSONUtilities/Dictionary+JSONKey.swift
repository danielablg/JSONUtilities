//
//  Dictionary+JSONKey.swift
//  JSONUtilities
//
//  Created by Luciano Marisi on 05/03/2016.
//  Copyright © 2016 Luciano Marisi All rights reserved.
//

import Foundation

/// Protocol used for defining the valid JSON types, i.e. Int, Double, Float, String and Bool
public protocol JSONRawType {}
extension Int : JSONRawType {}
extension Double : JSONRawType {}
extension Float : JSONRawType {}
extension String : JSONRawType {}
extension Bool : JSONRawType {}

// Simple protocol used to extend a JSONDictionary
public protocol StringProtocol {
  func components(separatedBy: String) -> [String]
}
extension String: StringProtocol {}

extension Dictionary where Key: StringProtocol {
  
  // MARK: JSONRawType type
  
  /// Decode a mandatory JSON raw type
  public func jsonKeyPath<ReturnType : JSONRawType>(_ key: Key) throws -> ReturnType {
    
    guard let value = self[keyPath: key] as? ReturnType else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    return value
  }
  
  /// Decode an optional JSON raw type
  public func jsonKeyPath<ReturnType : JSONRawType>(_ key: Key) -> ReturnType? {
    return self[keyPath: key] as? ReturnType
  }
  
  // MARK: [JSONRawType] type
  
  /// Decode an Array of mandatory JSON raw types
  public func jsonKeyPath<ReturnType : JSONRawType>(_ key: Key) throws -> [ReturnType] {
    guard let value = self[keyPath: key] as? [ReturnType] else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    return value
  }
  
  /// Decode an Array of optional JSON raw types
  public func jsonKeyPath<ReturnType : JSONRawType>(_ key: Key) -> [ReturnType]? {
    return self[keyPath: key] as? [ReturnType]
  }
  
  // MARK: [String: Any] type
  
  /// Decodes as a raw Dictionary with a mandatory key
  public func jsonKeyPath(_ key: Key) throws -> JSONDictionary {
    
    guard let value = self[keyPath: key] as? JSONDictionary else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    return value
  }

  /// Decodes as a raw dictionary with an optional key
  public func jsonKeyPath(_ key: Key) -> JSONDictionary? {
    return self[keyPath: key] as? JSONDictionary
  }
  
  // MARK: [[String: Any]] type
  
  /// Decodes as a raw dictionary array with a mandatory key
  public func jsonKeyPath(_ key: Key) throws -> [JSONDictionary] {
    
    guard let value = self[keyPath: key] as? [JSONDictionary] else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    return value
  }
  
  /// Decodes as a raw ictionary array with an optional key
  public func jsonKeyPath(_ key: Key) -> [JSONDictionary]? {
    return self[keyPath: key] as? [JSONDictionary]
  }

  
  // MARK: Decodable types
  
  /// Decode a mandatory Decodable object
  public func jsonKeyPath<ReturnType : JSONObjectConvertible>(_ key: Key) throws -> ReturnType {
    return try ReturnType(jsonDictionary: JSONDictionaryForKey(key))
  }
  
  /// Decode an optional Decodable object
  public func jsonKeyPath<ReturnType : JSONObjectConvertible>(_ key: Key) -> ReturnType? {
    return try? ReturnType(jsonDictionary: JSONDictionaryForKey(key))
  }
  
  // MARK: [Decodable] types
  
  /// Decode an Array of mandatory Decodable objects
  public func jsonKeyPath<ReturnType : JSONObjectConvertible>(_ key: Key) throws -> [ReturnType] {
    return decodableObjectsArray(try JSONArrayForKey(key))
  }
  
  /// Decode an Array of optional Decodable objects
  public func jsonKeyPath<ReturnType : JSONObjectConvertible>(_ key: Key) -> [ReturnType]? {
    guard let jsonArray = try? JSONArrayForKey(key) else {
      return nil
    }
    return decodableObjectsArray(jsonArray)
  }
  
  // MARK: RawRepresentable type
  
  /// Decode a mandatory RawRepresentable
  public func jsonKeyPath<ReturnType : RawRepresentable>(_ key: Key) throws -> ReturnType where ReturnType.RawValue:JSONRawType {
    
    guard let rawValue = self[key] as? ReturnType.RawValue else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    
    guard let value = ReturnType(rawValue:rawValue) else {
      throw DecodingError.mandatoryRawRepresentableHasIncorrectValue(rawRepresentable: ReturnType.self, rawValue: rawValue)
    }
    
    return value
  }
  
  /// Decode an optional RawRepresentable
  public func jsonKeyPath<ReturnType : RawRepresentable>(_ key: Key) -> ReturnType? {
    guard let rawValue = self[key] as? ReturnType.RawValue else {
      return nil
    }
    return ReturnType(rawValue:rawValue)
  }
  
  
  // MARK: [RawRepresentable] type
  
  /// Decode an array of custom RawRepresentable types with a mandatory key
  public func jsonKeyPath<ReturnType : RawRepresentable>(_ key: Key) throws -> [ReturnType] where ReturnType.RawValue:JSONRawType {
    
    guard let jsonValues = self[key] as? [ReturnType.RawValue] else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    
    return jsonValues.flatMap {
      ReturnType(rawValue:$0)
    }
  }
  
  /// Optionally decode an array of RawRepresentable types with a mandatory key
  public func jsonKeyPath<ReturnType : RawRepresentable>(_ key: Key) -> [ReturnType]? where ReturnType.RawValue:JSONRawType {
    
    guard let jsonValues = self[key] as? [ReturnType.RawValue] else {
      return nil
    }
    
    return jsonValues.flatMap {
      ReturnType(rawValue:$0)
    }
  }
  
  // MARK: JSONPrimitiveConvertible type
  
  /// Decode a custom raw types with a mandatory key
  public func jsonKeyPath<JSONPrimitiveConvertibleType : JSONPrimitiveConvertible>(_ key: Key) throws -> JSONPrimitiveConvertibleType {
    
    guard let jsonValue = self[keyPath: key] as? JSONPrimitiveConvertibleType.JSONType else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    
    guard let transformedValue = JSONPrimitiveConvertibleType.from(jsonValue: jsonValue) else {
      throw JSONPrimitiveConvertibleError.couldNotTransformJSONValue(value: jsonValue)
    }
    
    return transformedValue
  }
  
  /// Optionally decode a custom raw types with a mandatory key
  public func jsonKeyPath<JSONPrimitiveConvertibleType : JSONPrimitiveConvertible>(_ key: Key) -> JSONPrimitiveConvertibleType? {
    
    guard let jsonValue = self[keyPath: key] as? JSONPrimitiveConvertibleType.JSONType else {
      return nil
    }
    
    return JSONPrimitiveConvertibleType.from(jsonValue: jsonValue)
  }
  
  // MARK: [JSONPrimitiveConvertible] type
  
  /// Decode an array of custom raw types with a mandatory key
  public func jsonKeyPath<JSONPrimitiveConvertibleType : JSONPrimitiveConvertible>(_ key: Key) throws -> [JSONPrimitiveConvertibleType] {
    
    guard let jsonValues = self[keyPath: key] as? [JSONPrimitiveConvertibleType.JSONType] else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    
    return jsonValues.flatMap {
      JSONPrimitiveConvertibleType.from(jsonValue: $0)
    }

  }

  /// Optionally decode an array custom raw types with a mandatory key
  public func jsonKeyPath<JSONPrimitiveConvertibleType : JSONPrimitiveConvertible>(_ key: Key) -> [JSONPrimitiveConvertibleType]? {
    
    guard let jsonValues = self[keyPath: key] as? [JSONPrimitiveConvertibleType.JSONType] else {
      return nil
    }
    
    return jsonValues.flatMap {
      JSONPrimitiveConvertibleType.from(jsonValue:$0)
    }
    
  }
  
  // MARK: JSONDictionary and JSONArray creation
  
  fileprivate func JSONDictionaryForKey(_ key: Key) throws -> JSONDictionary {
    guard let jsonDictionary = self[keyPath: key] as? JSONDictionary else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    return jsonDictionary
  }
  
  fileprivate func JSONArrayForKey(_ key: Key) throws -> JSONArray {
    guard let jsonArray = self[keyPath: key] as? JSONArray else {
      throw DecodingError.mandatoryKeyNotFound(key: key)
    }
    return jsonArray
  }
  
  // MARK: JSONArray decoding
  
  fileprivate func decodableObjectsArray<ReturnType : JSONObjectConvertible>(_ jsonArray: JSONArray) -> [ReturnType] {
    return jsonArray.flatMap {
      guard let castedJsonObject = $0 as? JSONDictionary else {
        return nil
      }
      
      return try? ReturnType(jsonDictionary: castedJsonObject)
    }
  }

}