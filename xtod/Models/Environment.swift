//
//  Environment.swift
//  xtod
//
//  Created by Zack Adlington on 29/01/2026.
//

import Foundation

public enum Environment {
    enum Keys {
        static let openAIAPIKey = "OPENAI_API_KEY"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Could not access info dictionary.")
        }
        return dict
    }()
    
    static let apiKey: String = {
        guard let apiKeyString = Environment.infoDictionary[Keys.openAIAPIKey] as? String else {
            fatalError("OpenAI API key not set.  Is there an OpenAIAPIKEY.xcconfig in the project?")
        }
        return apiKeyString
    }()
}
