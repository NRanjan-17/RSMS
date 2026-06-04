//
//  NativeVideoCallView.swift
//  luxury
//
//  Created by RSMS App on 04/06/26.
//

import SwiftUI
import Daily

struct NativeVideoCallView: View {
    @Environment(\.dismiss) private var dismiss
    let meetingURL: URL
    
    @StateObject private var dailyManager = DailyManager()
    
    @State private var isScreenSharing = false
    @State private var isWhiteboardActive = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Main Video Area (Customer)
            if let remoteTrack = dailyManager.remoteVideoTrack {
                DailySwiftUIView(track: remoteTrack)
                    .ignoresSafeArea()
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.gold)
                        .padding(.bottom, 8)
                    Text("Waiting for client to join...")
                        .font(AppFonts.sansSerif(size: 16))
                        .foregroundStyle(.gray)
                    Text("Connection successful. You are currently the only participant.")
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(.gray.opacity(0.7))
                        .padding(.top, 4)
                    Spacer()
                }
            }
            
            // Whiteboard Overlay
            if isWhiteboardActive {
                WhiteboardView()
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            // UI Overlay
            VStack {
                // Top Bar
                HStack {
                    StatusBadge(text: "Live Consultation", status: .success)
                    Spacer()
                    Button(action: {
                        dailyManager.flipCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .padding(12)
                            .glassEffectWithFallback(in: .circle)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Floating PIP for Local User (Associate)
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.3))
                        
                        if let localTrack = dailyManager.localVideoTrack, !dailyManager.isCameraOff {
                            DailySwiftUIView(track: localTrack)
                        } else {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(.largeTitle)
                        }
                    }
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.trailing, 24)
                    .padding(.bottom, 16)
                }
                
                // Liquid Glass Control Bar
                HStack(spacing: 24) {
                    ControlButton(
                        icon: dailyManager.isMuted ? "mic.slash.fill" : "mic.fill",
                        isActive: dailyManager.isMuted,
                        activeColor: .red
                    ) {
                        dailyManager.toggleMic()
                    }
                    
                    ControlButton(
                        icon: dailyManager.isCameraOff ? "video.slash.fill" : "video.fill",
                        isActive: dailyManager.isCameraOff,
                        activeColor: .red
                    ) {
                        dailyManager.toggleCamera()
                    }
                    
                    ControlButton(
                        icon: "shareplay",
                        isActive: isScreenSharing,
                        activeColor: AppColors.gold
                    ) {
                        isScreenSharing.toggle()
                    }
                    
                    ControlButton(
                        icon: "pencil.tip.crop.circle",
                        isActive: isWhiteboardActive,
                        activeColor: AppColors.gold
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isWhiteboardActive.toggle()
                        }
                    }
                    
                    Button(action: {
                        dailyManager.leave()
                        dismiss()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: .red.opacity(0.4), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .glassEffectWithFallback(in: .capsule)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 24)
            }
            .zIndex(2) // Ensure the UI Overlay is always on top of the whiteboard
        }
        .onAppear {
            dailyManager.join(url: meetingURL)
        }
        .onDisappear {
            dailyManager.leave()
        }
    }
}

// Custom Liquid Glass Button
private struct ControlButton: View {
    let icon: String
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(isActive ? .white : AppColors.text)
                .frame(width: 50, height: 50)
                .background(
                    isActive ? activeColor : Color.clear
                )
                .clipShape(Circle())
        }
    }
}

// Glass Effect Extension for backward compatibility
extension View {
    @ViewBuilder
    func glassEffectWithFallback(
        in shape: some Shape = .rect
    ) -> some View {
        #if compiler(>=6.0)
        if #available(iOS 26, *) {
            self.glassEffect(.regular.interactive(), in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
        #else
        self.background(.ultraThinMaterial, in: shape)
        #endif
    }
}

// Simple Whiteboard View
struct WhiteboardView: View {
    @State private var lines: [[CGPoint]] = []
    
    var body: some View {
        ZStack {
            // Blurred dark overlay
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Live Whiteboard")
                        .font(AppFonts.sansSerif(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                    Button("Clear") {
                        lines.removeAll()
                    }
                    .font(AppFonts.sansSerif(size: 14))
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Drawing Canvas
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        guard let firstPoint = line.first else { continue }
                        path.move(to: firstPoint)
                        for point in line.dropFirst() {
                            path.addLine(to: point)
                        }
                        context.stroke(path, with: .color(AppColors.gold), lineWidth: 3)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let currentPoint = value.location
                            if lines.isEmpty || value.translation.width == 0 && value.translation.height == 0 {
                                lines.append([currentPoint])
                            } else {
                                lines[lines.count - 1].append(currentPoint)
                            }
                        }
                )
                .background(AppColors.surface.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(24)
            }
        }
    }
}
