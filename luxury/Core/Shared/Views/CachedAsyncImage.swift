import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let contentPhase: ((AsyncImagePhase) -> Content)?
    let contentImage: ((Image) -> Content)?
    let placeholder: (() -> Placeholder)?
    
    @State private var phase: AsyncImagePhase = .empty
    
    // Init for AsyncImagePhase
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) where Placeholder == EmptyView {
        self.url = url
        self.contentPhase = content
        self.contentImage = nil
        self.placeholder = nil
    }
    
    // Init for Image and Placeholder
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.contentPhase = nil
        self.contentImage = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let contentPhase = contentPhase {
                contentPhase(phase)
            } else if let contentImage = contentImage, let placeholder = placeholder {
                switch phase {
                case .empty:
                    placeholder()
                case .success(let image):
                    contentImage(image)
                case .failure:
                    placeholder()
                @unknown default:
                    placeholder()
                }
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            return
        }
        
        let key = url.absoluteString
        
        // 1. Check Cache
        if let cachedImage = await CacheManager.shared.getImage(bucket: "catalog", key: key) {
            await MainActor.run {
                self.phase = .success(Image(uiImage: cachedImage))
            }
            return
        }
        
        // 2. Fetch from Network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                await MainActor.run {
                    self.phase = .success(Image(uiImage: downloadedImage))
                }
                await CacheManager.shared.storeImage(downloadedImage, bucket: "catalog", key: key)
            } else {
                await MainActor.run {
                    self.phase = .failure(URLError(.cannotDecodeRawData))
                }
            }
        } catch {
            await MainActor.run {
                self.phase = .failure(error)
            }
        }
    }
}
