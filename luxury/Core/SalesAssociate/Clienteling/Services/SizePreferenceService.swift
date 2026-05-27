//
//  SizePreferenceService.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation

final class SizePreferenceService {
    static let shared = SizePreferenceService()
    
    private init() {}
    
    private func localKey(for clientId: UUID) -> String {
        return "luxury_sizes_\(clientId.uuidString)"
    }
    
    func fetchSizePreference(clientId: UUID) -> ClientSizePreference {
        let key = localKey(for: clientId)
        
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                return try JSONDecoder().decode(ClientSizePreference.self, from: data)
            } catch {
                print("Error decoding local sizes: \(error)")
            }
        }
        

        // Default empty preferences for new clients
        return ClientSizePreference(id: clientId)
    }
    
    func saveSizePreference(_ sizes: ClientSizePreference, for clientId: UUID) {
        let key = localKey(for: clientId)
        do {
            let data = try JSONEncoder().encode(sizes)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding local sizes: \(error)")
        }
    }
}
