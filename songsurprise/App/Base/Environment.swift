//
//  Environment.swift
//  songsurprise
//
//  Created by resoul on 11.09.2024.
//

import Foundation

struct Environment {
    enum Keys {
        static let BASE_URL = "BASE_URL"
        static let ANON_KEY = "ANON_KEY"
    }
    
    static let BASE_URL: String = {
        guard let baseURLProperty = Bundle.main.object(forInfoDictionaryKey: Keys.BASE_URL) as? String else {
            fatalError("BASE URL not found")
        }
        
        return baseURLProperty
    }()
    
    static let ANON_KEY: String = {
        guard let baseURLProperty = Bundle.main.object(forInfoDictionaryKey: Keys.ANON_KEY) as? String else {
            fatalError("ANON KEY not found")
        }
        
        return baseURLProperty
    }()
}
