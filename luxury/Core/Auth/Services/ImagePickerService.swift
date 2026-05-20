//
//  ImagePickerService.swift
//  luxury
//
//  Created by Codex on 20/05/26.
//

import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct PickedImageAsset: Equatable {
    let data: Data
    let fileExtension: String
    let contentType: String
}

enum ImagePickerServiceError: LocalizedError {
    case noSelection
    case unsupportedType
    case emptyData

    var errorDescription: String? {
        switch self {
        case .noSelection:
            return "Please select an image."
        case .unsupportedType:
            return "Selected file is not a supported image."
        case .emptyData:
            return "Selected image could not be loaded."
        }
    }
}

final class ImagePickerService {
    func loadImage(from item: PhotosPickerItem?) async throws -> PickedImageAsset {
        guard let item else {
            throw ImagePickerServiceError.noSelection
        }

        guard let type = item.supportedContentTypes.first(where: { $0.conforms(to: .image) }) else {
            throw ImagePickerServiceError.unsupportedType
        }

        guard let data = try await item.loadTransferable(type: Data.self), !data.isEmpty else {
            throw ImagePickerServiceError.emptyData
        }

        return PickedImageAsset(
            data: data,
            fileExtension: type.preferredFilenameExtension ?? "jpg",
            contentType: type.preferredMIMEType ?? "image/jpeg"
        )
    }
}
