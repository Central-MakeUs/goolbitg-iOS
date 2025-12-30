//
//  DiscordMessageManager.swift
//  Data
//
//  Created by Jae hyung Kim on 6/23/25.
//

import Foundation

final actor DiscordMessageManager {
    
    static let shared = DiscordMessageManager()
    private let serverDeveloper = "<@\(SecretKeys.neoTagID)>"
    
    private init() {}
    
    private var corsErrorTrigger = false
    private var serverError500Trigger = false
    
    private enum errorMessage {
        case corsError
        
        var message: String {
            switch self {
            case .corsError:
                return "CORS Error 발생"
            }
        }
    }
    
    func sendCorsMessage() {
        if corsErrorTrigger {
            return
        }
        guard let webhookURL = URL(string: SecretKeys.discordWebHookURL) else {
            return
        }
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let message = makeMessage(message: errorMessage.corsError.message)
        
        let payload: [String: Any] = ["content": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request).resume()
        self.corsErrorTrigger = true
    }
    
    func sendMessage500(message: String) {
        if serverError500Trigger { return }
        
        guard let webhookURL = URL(string: SecretKeys.discordWebHookURL) else {
            return
        }
        
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = ["content": makeMessage(message: message)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request).resume()
        self.serverError500Trigger = true
    }
    
    private func makeMessage(message: String) -> String {
        return """
\(serverDeveloper)
# iOS ServerError Message : 
> \(message)
"""
    }
}
