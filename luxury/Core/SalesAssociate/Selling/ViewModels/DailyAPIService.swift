//
//  DailyAPIService.swift
//  luxury
//
//  Created by RSMS App on 04/06/26.
//

import Foundation

struct DailyRoomResponse: Codable {
    let url: String
    let name: String
}

class DailyAPIService {
    
    /// Creates a unique, short-lived video room using the Daily REST API.
    /// Note: In a real production app, this API call should be made from your backend (e.g. Supabase Edge Function)
    /// to avoid hardcoding your secret API key in the iOS app.
    static func createRoom(apiKey: String) async throws -> String {
        guard let url = URL(string: "https://api.daily.co/v1/rooms") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Generate a room that expires in 1 hour
        let expireTime = Int(Date().addingTimeInterval(3600).timeIntervalSince1970)
        let body: [String: Any] = [
            "properties": [
                "exp": expireTime,
                "enable_chat": true,
                "enable_screenshare": true
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let roomResponse = try JSONDecoder().decode(DailyRoomResponse.self, from: data)
        return roomResponse.url
    }
}
