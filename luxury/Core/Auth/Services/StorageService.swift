//
//  StorageService.swift
//  luxury
//
//  Created by Aditya Chauhan on 19/05/26.
//

import Foundation
import Supabase

final class StorageService {
    private let client = SupabaseManager.shared.client
    private let bucket = "rsms-uploads"
    
    func uploadAvatar(image: PickedImageAsset, userId: UUID) async throws -> String {
        let path = "avatars/\(userId.uuidString)-\(Int(Date().timeIntervalSince1970)).\(image.fileExtension)"
        try await upload(image: image, path: path)
        return try client.storage.from(bucket).getPublicURL(path: path).absoluteString
    }
    
    func uploadResume(image: PickedImageAsset, userId: UUID) async throws -> String {
        let path = "resumes/\(userId.uuidString)-\(Int(Date().timeIntervalSince1970)).\(image.fileExtension)"
        try await upload(image: image, path: path)
        return try client.storage.from(bucket).getPublicURL(path: path).absoluteString
    }
    
    func uploadCatalogImage(image: PickedImageAsset) async throws -> String {
        let path = "catalogs/\(UUID().uuidString)-\(Int(Date().timeIntervalSince1970)).\(image.fileExtension)"
        try await upload(image: image, path: path)
        return try client.storage.from(bucket).getPublicURL(path: path).absoluteString
    }
    
    private func upload(image: PickedImageAsset, path: String) async throws {
        let session = try await client.auth.session
        var request = URLRequest(url: storageObjectURL(path: path))
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue(image.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("3600", forHTTPHeaderField: "Cache-Control")
        request.setValue("false", forHTTPHeaderField: "x-upsert")
        request.httpBody = image.data
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StorageUploadError(message: "Storage upload failed: invalid server response")
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = storageErrorMessage(from: data, statusCode: httpResponse.statusCode)
            throw StorageUploadError(message: message)
        }
    }
    
    private func storageObjectURL(path: String) -> URL {
        var url = SupabaseConfig.url
        ["storage", "v1", "object", bucket].forEach {
            url.appendPathComponent($0)
        }
        path.split(separator: "/").forEach {
            url.appendPathComponent(String($0))
        }
        return url
    }
    
    private func storageErrorMessage(from data: Data, statusCode: Int) -> String {
        if let response = try? JSONDecoder().decode(StorageErrorResponse.self, from: data) {
            let detail = response.message ?? response.error ?? response.statusCode
            if let detail, !detail.isEmpty {
                return "Storage upload failed (\(statusCode)): \(detail)"
            }
        }
        
        if let body = String(data: data, encoding: .utf8), !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Storage upload failed (\(statusCode)): \(body)"
        }
        
        return "Storage upload failed with status \(statusCode)"
    }
}

private struct StorageErrorResponse: Decodable {
    let message: String?
    let error: String?
    let statusCode: String?
}

private struct StorageUploadError: LocalizedError {
    let message: String
    
    var errorDescription: String? {
        message
    }
}
