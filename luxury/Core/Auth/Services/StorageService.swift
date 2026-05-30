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

    func uploadDamagePhoto(image: PickedImageAsset, productId: UUID, serial: String) async throws -> String {
        let safeSerial = serial
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
        let path = "damage-reports/\(productId.uuidString)-\(safeSerial)-\(Int(Date().timeIntervalSince1970)).\(image.fileExtension)"
        try await upload(image: image, path: path)
        return try client.storage.from(bucket).getPublicURL(path: path).absoluteString
    }
    
    private func upload(image: PickedImageAsset, path: String) async throws {
        try await client.storage
            .from(bucket)
            .upload(
                path: path,
                file: image.data,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: image.contentType,
                    upsert: true
                )
            )
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
