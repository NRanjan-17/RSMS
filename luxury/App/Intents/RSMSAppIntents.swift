import AppIntents
import SwiftUI

// 1. Check Inventory Intent
struct CheckInventoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Product Inventory"
    static var description = IntentDescription("Checks the availability of a specific product in your boutique.")
    
    @Parameter(title: "Product Name")
    var productName: String
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // In a real app, you would query your local CoreData or a backend API here.
        // For demonstration, we simulate finding the product.
        
        let found = Int.random(in: 0...5)
        
        let dialog = IntentDialog(stringLiteral: found > 0 ? "You have \(found) units of \(productName) in stock." : "Sorry, \(productName) is currently out of stock.")
        
        return .result(
            dialog: dialog,
            view: InventorySnippetView(productName: productName, count: found)
        )
    }
}

struct InventorySnippetView: View {
    let productName: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inventory Check")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(productName)
                    .font(.headline)
                Spacer()
                Text("\(count) in stock")
                    .font(.subheadline)
                    .foregroundStyle(count > 0 ? .green : .red)
            }
        }
        .padding()
    }
}

// 2. View Daily Targets Intent
struct ViewDailyTargetsIntent: AppIntent {
    static var title: LocalizedStringResource = "View Daily Sales Target"
    static var description = IntentDescription("Shows your current sales progress for the day.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Fetch target from view models or storage
        let target = "$50,000"
        let current = "$42,500"
        
        let dialog = IntentDialog(stringLiteral: "Your daily target is \(target) and you have achieved \(current) so far. Keep it up!")
        return .result(dialog: dialog)
    }
}

// Provider to automatically register these shortcuts
struct RSMSAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckInventoryIntent(),
            phrases: [
                "Check inventory in \(.applicationName)",
                "Search \(.applicationName) for a product",
                "Find a product in \(.applicationName)"
            ],
            shortTitle: "Check Inventory",
            systemImageName: "shippingbox.fill"
        )
        
        AppShortcut(
            intent: ViewDailyTargetsIntent(),
            phrases: [
                "What are my \(.applicationName) targets today?",
                "Check daily sales in \(.applicationName)",
                "Show my \(.applicationName) progress"
            ],
            shortTitle: "View Daily Targets",
            systemImageName: "chart.bar.fill"
        )
    }
}
