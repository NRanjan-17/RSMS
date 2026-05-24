//
//  SFSNotificationService.swift
//  luxury
//

import Foundation
import Observation
import Supabase
import UserNotifications
import UIKit

@Observable
final class SFSNotificationService {
    var hasNewOrder: Bool = false
    var lastOrderMessage: String = ""
    
    private var channel: RealtimeChannelV2?
    
    func startListening() {
        channel = SupabaseManager.shared.client.realtimeV2.channel("sfs_notifications")
        
        Task {
            for await event in channel!.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "purchased_items"
            ) {
                if let status = event.record["status"]?.stringValue, status == "Pending" {
                    await MainActor.run {
                        let idRaw = event.record["id"]?.stringValue ?? "Unknown"
                        let prefix = idRaw.prefix(8).uppercased()
                        self.lastOrderMessage = "New SFS Order Received: \(prefix)"
                        self.hasNewOrder = true
                        
                        // Play a haptic vibration to grab attention
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        NotificationCenter.default.post(name: NSNotification.Name("SFSOrderReceived"), object: nil)
                        
                        // Auto-hide toast after 4 seconds
                        Task {
                            try? await Task.sleep(nanoseconds: 4_000_000_000)
                            self.hasNewOrder = false
                        }
                    }
                }
            }
        }
        
        Task {
            await channel?.subscribe()
        }
    }
    
    func stopListening() {
        Task {
            if let channel = channel {
                await SupabaseManager.shared.client.removeChannel(channel)
            }
        }
    }
}
