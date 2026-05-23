//
//  ScannerService.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import Foundation
import AVFoundation

@Observable
final class ScannerService: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession
    var isRunning: Bool = false
    var continuousMode: Bool = true
    var debounceSeconds: TimeInterval = 2.0
    var onScannedCode: ((String) -> Void)?
    
    private var lastScannedCode: String?
    private var lastScannedTime: Date?
    private var isConfigured = false
    
    override init() {
        self.captureSession = AVCaptureSession()
        super.init()
    }
    
    func configure() -> Bool {
        if isConfigured {
            return true
        }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return false }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return false
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return false
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417, .aztec, .code128]
        } else {
            return false
        }
        
        isConfigured = true
        return true
    }
    
    func start() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.captureSession.startRunning()
                DispatchQueue.main.async {
                    self?.isRunning = true
                }
            }
        }
    }
    
    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            isRunning = false
        }
    }
    
    func resetDebounce() {
        lastScannedCode = nil
        lastScannedTime = nil
    }
    
    func playErrorFeedback() {
        AudioServicesPlaySystemSound(1053) 
    }
    
    func playSuccessFeedback() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        let now = Date()
        
        if continuousMode {
            if let lastTime = lastScannedTime, let lastCode = lastScannedCode, stringValue == lastCode {
                if now.timeIntervalSince(lastTime) < debounceSeconds {
                    return
                }
            }
        } else {
            stop()
        }
        
        lastScannedCode = stringValue
        lastScannedTime = now
        
        onScannedCode?(stringValue)
    }
}
