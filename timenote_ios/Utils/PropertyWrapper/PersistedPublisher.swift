//
//  PersistedPublisher.swift
//  Timenote
//
//  Created by Aziz Essid on 13/10/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import os.log

@propertyWrapper
struct PersistedPublisher<Value: Codable> {
    private let key             : String
    public  var wrappedValue    : Value? { get {
        return self.getObjectValue()
        } set {
            self.saveObject(newValue: newValue)
        }}
    
    public init(key: String) {
        self.key = key
    }
    
    private func saveObject(newValue: Value?) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.key)
        os_log("Upadted persisted value : access = %{PRIVATE}@, refresh = %{PRIVATE}@", log : OSLog.persistedCycle, type: .debug, self.key, newValue as! CVarArg)
    }
    
    private func getObjectValue() -> Value? {
        guard let valueData = UserDefaults.standard.value(forKey: self.key) as? Data, let objectValue = try? PropertyListDecoder().decode(Value.self, from: valueData) else { return nil }
        return objectValue
    }
}
