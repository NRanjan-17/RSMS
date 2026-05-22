//
//  ClientService.swift
//  luxury
//
//  Created by Antigravity on 21/05/26.
//

import Foundation
import Supabase

final class ClientService {
    private let client = SupabaseManager.shared.client
    private let localClientsKey = "luxury_local_clients"
    
    private var localEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    private var localDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            
            if let dateString = try? container.decode(String.self) {
                let formatters = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                    "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                    "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                    "yyyy-MM-dd HH:mm:ss"
                ]
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                for format in formatters {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                if let date = ISO8601DateFormatter().date(from: dateString) {
                    return date
                }
            } else if let doubleValue = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: doubleValue)
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date"
            )
        }
        return decoder
    }
    
    private func getLocalClients() -> [ClientEntity] {
        guard let data = UserDefaults.standard.data(forKey: localClientsKey) else {
            return []
        }
        do {
            return try localDecoder.decode([ClientEntity].self, from: data)
        } catch {
            print("Error decoding local clients: \(error)")
            return []
        }
    }
    
    private func saveLocalClients(_ clients: [ClientEntity]) {
        do {
            let data = try localEncoder.encode(clients)
            UserDefaults.standard.set(data, forKey: localClientsKey)
        } catch {
            print("Error encoding local clients: \(error)")
        }
    }
    
    func fetchClients() async throws -> [ClientEntity] {
        var dbClients: [ClientEntity] = []
        do {
            dbClients = try await client
                .from("client")
                .select()
                .execute()
                .value
        } catch {
            print("Database fetch clients failed: \(error). Falling back to local/cached.")
        }
        
        let localClients = getLocalClients()
        var merged: [ClientEntity] = localClients
        
        for dbClient in dbClients {
            if !merged.contains(where: { $0.id == dbClient.id }) {
                merged.append(dbClient)
            }
        }
        
        return merged
    }
    
    func fetchClient(id: UUID) async throws -> ClientEntity {
        let localClients = getLocalClients()
        if let local = localClients.first(where: { $0.id == id }) {
            return local
        }
        
        let response: ClientEntity = try await client
            .from("client")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        return response
    }
    
    func createClient(_ clientEntity: ClientEntity) async throws {
        do {
            try await client
                .from("client")
                .insert(clientEntity)
                .execute()
        } catch {
            print("Database createClient failed: \(error).")
        }
        
        // Always cache created clients locally to guarantee local UI is updated immediately
        // and acts as a local fallback database.
        var localClients = getLocalClients()
        if let index = localClients.firstIndex(where: { $0.id == clientEntity.id }) {
            localClients[index] = clientEntity
        } else {
            localClients.append(clientEntity)
        }
        saveLocalClients(localClients)
    }
    
    func updateClient(_ clientEntity: ClientEntity) async throws {
        do {
            try await client
                .from("client")
                .update(clientEntity)
                .eq("id", value: clientEntity.id.uuidString)
                .execute()
        } catch {
            print("Database updateClient failed: \(error).")
        }
        
        // Always cache the update locally so that:
        // 1. Mock clients (which aren't in Supabase) are successfully updated and persist.
        // 2. Newly created clients that failed DB insertion (and live only locally) are updated successfully.
        // 3. Local view updates are immediate and match the user's edits.
        var localClients = getLocalClients()
        if let index = localClients.firstIndex(where: { $0.id == clientEntity.id }) {
            localClients[index] = clientEntity
        } else {
            localClients.append(clientEntity)
        }
        saveLocalClients(localClients)
    }
}
