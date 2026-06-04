//
//  DailyManager.swift
//  luxury
//
//  Created by RSMS App on 04/06/26.
//

import Foundation
import Daily
import Combine
import SwiftUI

class DailyManager: NSObject, ObservableObject, CallClientDelegate {
    let callClient = CallClient()
    
    @Published var localVideoTrack: VideoTrack?
    @Published var remoteVideoTrack: VideoTrack?
    @Published var isMuted = false
    @Published var isCameraOff = true
    
    override init() {
        super.init()
        callClient.delegate = self
    }
    
    func join(url: URL) {
        Task {
            do {
                // Ensure the hardware is turned off before we even connect to the room
                _ = try await callClient.updateInputs(.set(camera: .set(isEnabled: .set(false))))
                _ = try await callClient.join(url: url)
            } catch {
                print("Failed to join call: \(error)")
            }
        }
    }
    
    func leave() {
        Task {
            do {
                _ = try await callClient.leave()
            } catch {
                print("Failed to leave call: \(error)")
            }
        }
    }
    
    func toggleMic() {
        let isEnabled = !isMuted
        Task {
            do {
                _ = try await callClient.updateInputs(.set(microphone: .set(isEnabled: .set(!isEnabled))))
                DispatchQueue.main.async {
                    self.isMuted.toggle()
                }
            } catch {
                print("Failed to toggle mic: \(error)")
            }
        }
    }
    
    func toggleCamera() {
        let isEnabled = !isCameraOff
        Task {
            do {
                _ = try await callClient.updateInputs(.set(camera: .set(isEnabled: .set(!isEnabled))))
                DispatchQueue.main.async {
                    self.isCameraOff.toggle()
                }
            } catch {
                print("Failed to toggle camera: \(error)")
            }
        }
    }
    
    func flipCamera() {
        let currentFacingMode = callClient.inputs.camera.settings.facingMode
        Task {
            do {
                if currentFacingMode == .user {
                    _ = try await callClient.updateInputs(.set(camera: .set(settings: .set(facingMode: .set(.environment)))))
                } else {
                    _ = try await callClient.updateInputs(.set(camera: .set(settings: .set(facingMode: .set(.user)))))
                }
            } catch {
                print("Failed to flip camera: \(error)")
            }
        }
    }
    
    // MARK: - CallClientDelegate
    func callClient(_ callClient: CallClient, participantJoined participant: Participant) {
        updateTracks()
    }
    
    func callClient(_ callClient: CallClient, participantUpdated participant: Participant) {
        updateTracks()
    }
    
    func callClient(_ callClient: CallClient, participantLeft participant: Participant, withReason reason: ParticipantLeftReason) {
        updateTracks()
    }
    
    private func updateTracks() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Local track
            self.localVideoTrack = self.callClient.participants.local.media?.camera.track
            
            // Remote track (assuming 1-on-1 consultation for now)
            if let remoteParticipant = self.callClient.participants.all.values.first(where: { !$0.info.isLocal }) {
                self.remoteVideoTrack = remoteParticipant.media?.camera.track
            } else {
                self.remoteVideoTrack = nil
            }
        }
    }
}

// MARK: - SwiftUI Wrapper for Daily VideoView
struct DailySwiftUIView: UIViewRepresentable {
    var track: VideoTrack?
    
    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        view.videoScaleMode = .fill // Fills the available space smoothly
        return view
    }
    
    func updateUIView(_ uiView: VideoView, context: Context) {
        uiView.track = track
    }
}
