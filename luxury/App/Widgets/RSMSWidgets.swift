//
//  RSMSWidgets.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import UIKit

struct FaceIDIcon: View {
    var color: Color = .white
    var size: CGFloat = 20
    
    var body: some View {
        Canvas { context, size in
            let path = Path { p in
                p.move(to: CGPoint(x: size.width * 0.05, y: size.height * 0.275))
                p.addLine(to: CGPoint(x: size.width * 0.05, y: size.height * 0.125))
                p.addQuadCurve(to: CGPoint(x: size.width * 0.125, y: size.height * 0.05), control: CGPoint(x: size.width * 0.05, y: size.height * 0.05))
                p.addLine(to: CGPoint(x: size.width * 0.275, y: size.height * 0.05))
                
                p.move(to: CGPoint(x: size.width * 0.725, y: size.height * 0.05))
                p.addLine(to: CGPoint(x: size.width * 0.875, y: size.height * 0.05))
                p.addQuadCurve(to: CGPoint(x: size.width * 0.95, y: size.height * 0.125), control: CGPoint(x: size.width * 0.95, y: size.height * 0.05))
                p.addLine(to: CGPoint(x: size.width * 0.95, y: size.height * 0.275))
                
                p.move(to: CGPoint(x: size.width * 0.95, y: size.height * 0.725))
                p.addLine(to: CGPoint(x: size.width * 0.95, y: size.height * 0.875))
                p.addQuadCurve(to: CGPoint(x: size.width * 0.875, y: size.height * 0.95), control: CGPoint(x: size.width * 0.95, y: size.height * 0.95))
                p.addLine(to: CGPoint(x: size.width * 0.725, y: size.height * 0.95))
                
                p.move(to: CGPoint(x: size.width * 0.275, y: size.height * 0.95))
                p.addLine(to: CGPoint(x: size.width * 0.125, y: size.height * 0.95))
                p.addQuadCurve(to: CGPoint(x: size.width * 0.05, y: size.height * 0.875), control: CGPoint(x: size.width * 0.05, y: size.height * 0.95))
                p.addLine(to: CGPoint(x: size.width * 0.05, y: size.height * 0.725))
                
                p.move(to: CGPoint(x: size.width * 0.35, y: size.height * 0.375))
                p.addLine(to: CGPoint(x: size.width * 0.35, y: size.height * 0.46))
                
                p.move(to: CGPoint(x: size.width * 0.65, y: size.height * 0.375))
                p.addLine(to: CGPoint(x: size.width * 0.65, y: size.height * 0.46))
                
                p.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.49))
                p.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.6))
                
                p.move(to: CGPoint(x: size.width * 0.375, y: size.height * 0.675))
                p.addQuadCurve(to: CGPoint(x: size.width * 0.625, y: size.height * 0.675), control: CGPoint(x: size.width * 0.5, y: size.height * 0.775))
            }
            context.stroke(path, with: .color(color), lineWidth: 1.5)
        }
        .frame(width: size, height: size)
    }
}

struct GoldRule: View {
    var width: CGFloat
    var height: CGFloat = 0.75
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        AppColors.gold.opacity(0),
                        AppColors.gold.opacity(0.9),
                        AppColors.gold.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
    }
}

struct LuxuryProgressStyle: ProgressViewStyle {
    var height: CGFloat = 3
    var color: Color = AppColors.gold
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.surface2)
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(configuration.fractionCompleted ?? 0))
            }
        }
        .frame(height: height)
    }
}

struct LuxuryToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? AppColors.gold : AppColors.tertiary)
                    .frame(width: 44, height: 26)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 3)
            }
            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

struct Sparkline: View {
    var points: [Double]
    var color: Color = AppColors.gold
    var height: CGFloat = 80
    
    var body: some View {
        GeometryReader { geo in
            let maxPt = points.max() ?? 1
            let w = geo.size.width
            let h = geo.size.height
            let step = points.count > 1 ? w / CGFloat(points.count - 1) : w
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    for (i, pt) in points.enumerated() {
                        let x = CGFloat(i) * step
                        let y = h - (CGFloat(pt) / CGFloat(maxPt)) * h
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()
                }
                .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.25), color.opacity(0.0)]), startPoint: .top, endPoint: .bottom))
                
                Path { path in
                    for (i, pt) in points.enumerated() {
                        let x = CGFloat(i) * step
                        let y = h - (CGFloat(pt) / CGFloat(maxPt)) * h
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(height: height)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterial)
                .ignoresSafeArea()
            
            ProgressView()
                .tint(AppColors.gold)
                .scaleEffect(1.2)
        }
    }
}

private struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct RequestDetailSheet: View {
    let title: String
    let subtitle: String
    let details: [(String, String)]
    var avatarUrl: String? = nil
    var resumeUrl: String? = nil
    var isApproving = false
    var isRejecting = false
    var errorMessage: String? = nil
    var onApprove: () -> Void
    var onReject: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.surface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        HStack(spacing: 16) {
                            if let avatarUrl = avatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ZStack {
                                        AppColors.gold08
                                        ProgressView().tint(AppColors.gold).scaleEffect(0.8)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppColors.gold15, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(subtitle.uppercased())
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(2)
                                Text(title)
                                    .font(AppFonts.serif(size: 32, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        VStack(spacing: 20) {
                            ForEach(0..<details.count, id: \.self) { i in
                                HStack {
                                    Text(details[i].0)
                                        .font(AppFonts.sansSerif(size: 12))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(details[i].1)
                                        .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                if i < details.count - 1 {
                                    Divider().background(AppColors.gold15)
                                }
                            }
                        }
                        .padding(20)
                        .background(AppColors.background.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        if let resumeUrl = resumeUrl, let url = URL(string: resumeUrl) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("RESUME")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    HStack {
                                        Spacer()
                                        ProgressView().tint(AppColors.gold)
                                        Spacer()
                                    }
                                    .frame(height: 200)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                        }
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                .foregroundStyle(AppColors.error)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(28)
                }
                
                HStack(spacing: 16) {
                    Button(action: onReject) {
                        HStack(spacing: 8) {
                            if isRejecting {
                                ProgressView()
                                    .tint(AppColors.error)
                                    .controlSize(.small)
                            }
                            Text(isRejecting ? "Rejecting..." : "Reject")
                        }
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AppColors.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.error.opacity(0.3), lineWidth: 1))
                    }
                    .disabled(isApproving || isRejecting)
                    
                    CustomButton(title: "Approve Access", isLoading: isApproving, action: onApprove)
                        .disabled(isRejecting)
                }
                .padding(28)
                .background(AppColors.surface)
            }
        }
        .presentationDetents([.medium, .large])
    }
}
