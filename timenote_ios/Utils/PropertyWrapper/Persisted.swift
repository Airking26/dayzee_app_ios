//
//  PersistedArrat.swift
//  Timenote
//
//  Created by Aziz Essid on 9/21/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import os.log

@propertyWrapper
struct Persisted<Value: Codable> {
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
        UserDefaults.standard.set(try! JSONEncoder().encode(newValue), forKey: self.key)
        os_log("Upadted persisted value : access = %{PRIVATE}@, refresh = %{PRIVATE}@", log : OSLog.persistedCycle, type: .debug, self.key, try! JSONEncoder().encode(newValue) as CVarArg)
    }
    
    private func getObjectValue() -> Value? {
        guard let valueData = UserDefaults.standard.value(forKey: self.key) as? Data else { return nil }
        return try? JSONDecoder().decode(Value.self, from: valueData)
    }
}

