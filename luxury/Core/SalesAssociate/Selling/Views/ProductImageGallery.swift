//
//  ProductImageGallery.swift
//  luxury
//
//  Created by Kaushiki Rai on 25/05/26.
//

import SwiftUI

struct ProductImageGalleryView: View {
    let imageUrls: [String]?

    @State private var currentIndex = 0

    private var urls: [URL] {
        (imageUrls ?? []).filter { !$0.isEmpty }.compactMap { URL(string: $0) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if urls.isEmpty {
                emptyState
            } else {
                ZStack {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                            ZoomableImageView(url: url).tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 300)
                    .background(AppColors.surface)

                    chevrons
                }

                if urls.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<urls.count, id: \.self) { i in
                            Circle()
                                .fill(i == currentIndex ? AppColors.gold : AppColors.gold.opacity(0.25))
                                .frame(
                                    width:  i == currentIndex ? 8 : 5,
                                    height: i == currentIndex ? 8 : 5
                                )
                                .animation(.spring(duration: 0.3), value: currentIndex)
                        }
                    }
                    .padding(.top, 10)

                    Text("\(currentIndex + 1) / \(urls.count)")
                        .font(AppFonts.sansSerif(size: 11))
                        .foregroundStyle(AppColors.tertiary)
                        .padding(.bottom, 6)
                }
            }
        }
    }

    @ViewBuilder
    private var chevrons: some View {
        HStack {
            if currentIndex > 0 {
                chevronButton(.left) {
                    withAnimation(.spring(duration: 0.3)) { currentIndex -= 1 }
                }
            } else {
                Color.clear.frame(width: 44)
            }
            Spacer()
            if currentIndex < urls.count - 1 {
                chevronButton(.right) {
                    withAnimation(.spring(duration: 0.3)) { currentIndex += 1 }
                }
            } else {
                Color.clear.frame(width: 44)
            }
        }
        .padding(.horizontal, 12)
    }

    private func chevronButton(_ direction: ChevronDirection, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.black.opacity(0.45))
                    .frame(width: 36, height: 36)
                Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
            }
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        ZStack {
            Rectangle().fill(AppColors.surface).frame(height: 300)
            VStack(spacing: 10) {
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.gold.opacity(0.4))
                Text("NO IMAGE")
                    .font(AppFonts.sansSerif(size: 10))
                    .foregroundStyle(AppColors.tertiary)
                    .kerning(2)
            }
        }
    }

    private enum ChevronDirection { case left, right }
}

struct ZoomableImageView: View {
    let url: URL

    @State private var scale:      CGFloat = 1.0
    @State private var lastScale:  CGFloat = 1.0
    @State private var offset:     CGSize  = .zero
    @State private var lastOffset: CGSize  = .zero

    private let maxScale: CGFloat = 4.0
    private let minScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.75

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(AppColors.surface2)
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(AppColors.gold)
                            .scaleEffect(1.2)
                    }

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = min(max(lastScale * value, minScale), maxScale)
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale <= minScale { resetZoom() }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    guard scale > 1.0 else { return }
                                    offset = CGSize(
                                        width:  lastOffset.width  + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    guard scale > 1.0 else { return }
                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(duration: 0.35)) {
                                if scale > 1.0 {
                                    resetZoom()
                                } else {
                                    scale = 2.5
                                    lastScale = 2.5
                                }
                            }
                        }

                case .failure:
                    ZStack {
                        Rectangle().fill(AppColors.surface2)
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(AppColors.gold.opacity(0.4))
                    }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 300)
            .clipped()

            VStack(spacing: 0) {
                Button(action: zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 30))
                        .foregroundStyle(AppColors.gold)
                        .shadow(color: .black.opacity(0.4), radius: 4)
                }
                .disabled(scale >= maxScale)
                .opacity(scale >= maxScale ? 0.35 : 1)

                Button(action: zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 30))
                        .foregroundStyle(scale > 1.0 ? AppColors.gold : AppColors.gold.opacity(0.35))
                        .shadow(color: .black.opacity(0.4), radius: 4)
                }
                .disabled(scale <= minScale)
            }
            .padding(10)
        }
    }

    private func zoomIn() {
        withAnimation(.spring(duration: 0.3)) {
            scale = min(scale + zoomStep, maxScale)
            lastScale = scale
        }
    }

    private func zoomOut() {
        withAnimation(.spring(duration: 0.3)) {
            scale = max(scale - zoomStep, minScale)
            lastScale = scale
            if scale <= minScale { resetZoom() }
        }
    }

    private func resetZoom() {
        scale = minScale
        lastScale = minScale
        offset = .zero
        lastOffset = .zero
    }
}
