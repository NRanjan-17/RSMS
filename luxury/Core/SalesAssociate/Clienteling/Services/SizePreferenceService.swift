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
        
        // Fallback for mock clients during demo
        if clientId == Client.mockRahulId {
            let sizes = ClientSizePreference(id: clientId, ringSize: "9", wristSize: "18.5 cm", apparelSize: "L", shoeSize: "43")
            saveSizePreference(sizes, for: clientId)
            return sizes
        } else if clientId == Client.mockPriyaId {
            let sizes = ClientSizePreference(id: clientId, ringSize: "6", wristSize: "15 cm", apparelSize: "S", shoeSize: "38")
            saveSizePreference(sizes, for: clientId)
            return sizes
        } else if clientId == Client.mockDeepaId {
            let sizes = ClientSizePreference(id: clientId, ringSize: "7", wristSize: "16 cm", apparelSize: "M", shoeSize: "39")
            saveSizePreference(sizes, for: clientId)
            return sizes
        } else if clientId == Client.mockAnanyaId {
            let sizes = ClientSizePreference(id: clientId, ringSize: "5.5", wristSize: "14.5 cm", apparelSize: "XS", shoeSize: "37")
            saveSizePreference(sizes, for: clientId)
            return sizes
        } else if clientId == Client.mockVikramId {
            let sizes = ClientSizePreference(id: clientId, ringSize: "10", wristSize: "19.5 cm", apparelSize: "XL", shoeSize: "44")
            saveSizePreference(sizes, for: clientId)
            return sizes
        } else if clientId == Client.mockRohitId {
            let sizes = ClientSizePreference(id: clientId, ringSize: "9.5", wristSize: "18 cm", apparelSize: "L", shoeSize: "42")
            saveSizePreference(sizes, for: clientId)
            return sizes
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
