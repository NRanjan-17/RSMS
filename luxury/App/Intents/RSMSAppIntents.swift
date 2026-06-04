import AppIntents
import SwiftUI
import Supabase

// 1. Check Inventory Intent
struct CheckInventoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Product Inventory"
    static var description = IntentDescription("Checks the availability of a specific product in your boutique.")
    
    @Parameter(title: "Product")
    var product: ProductEntity
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let found = product.inStock ? Int.random(in: 1...5) : 0
        
        let dialog = IntentDialog(stringLiteral: found > 0 ? "You have \(found) units of \(product.name) in stock." : "Sorry, \(product.name) is currently out of stock.")
        
        return .result(
            dialog: dialog,
            view: InventorySnippetView(productName: product.name, count: found)
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
    static var shortcutTileColor: ShortcutTileColor { .blue }
    
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
        
        AppShortcut(
            intent: ViewAppointmentsIntent(),
            phrases: [
                "Show my appointments in \(.applicationName)",
                "View schedule in \(.applicationName)",
                "Open appointments in \(.applicationName)"
            ],
            shortTitle: "View Appointments",
            systemImageName: "calendar"
        )
        
        AppShortcut(
            intent: StartSaleIntent(),
            phrases: [
                "Start a sale in \(.applicationName)",
                "Open POS in \(.applicationName)",
                "Open cart in \(.applicationName)"
            ],
            shortTitle: "Start a Sale",
            systemImageName: "cart"
        )
    }
}

// 3. View Appointments Intent
struct ViewAppointmentsIntent: AppIntent {
    static var title: LocalizedStringResource = "View Appointments"
    static var description = IntentDescription("Opens your upcoming appointments in RSMS.")
    
    static var openAppWhenRun: Bool = true

    @Dependency
    private var saAppState: SalesAssociateAppState
    
    @Dependency
    private var appCoordinator: AppCoordinator

    @MainActor
    func perform() async throws -> some IntentResult {
        saAppState.selectedTab = .clients
        return .result()
    }
}

// 4. Start Sale Intent
struct StartSaleIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a Sale"
    static var description = IntentDescription("Opens the Point of Sale in RSMS.")
    
    static var openAppWhenRun: Bool = true

    @Dependency
    private var saAppState: SalesAssociateAppState
    
    @Dependency
    private var appCoordinator: AppCoordinator

    @MainActor
    func perform() async throws -> some IntentResult {
        saAppState.selectedTab = .pos
        return .result()
    }
}
import AppIntents
import SwiftUI
import CoreSpotlight

// MARK: - Product App Entity
struct ProductEntity: AppEntity, IndexedEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Product"
    static var defaultQuery = ProductEntityQuery()
    
    let id: UUID
    
    @Property(title: "Brand")
    var brand: String
    
    @Property(title: "Name")
    var name: String
    
    @Property(title: "Price")
    var price: String
    
    @Property(title: "In Stock")
    var inStock: Bool
    
    // CoreSpotlight integration for Visual Intelligence & Spotlight Search
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(brand) - \(name)",
            subtitle: LocalizedStringResource(stringLiteral: price),
            image: .init(systemName: "bag.fill")
        )
    }
    
    init(id: UUID, brand: String, name: String, price: String, inStock: Bool) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
        self.inStock = inStock
    }
    
    init(from product: Product) {
        self.id = product.id
        self.brand = product.brand
        self.name = product.name
        self.price = product.price
        self.inStock = product.inStock
    }
    
    init(from catalog: CatalogEntity) {
        self.id = catalog.id
        self.brand = catalog.brand
        self.name = catalog.name
        self.price = catalog.formattedPrice
        self.inStock = catalog.status == .active
    }
}

// MARK: - Entity Query for Siri & Spotlight Search
struct ProductEntityQuery: EntityQuery, EntityStringQuery {
    func entities(for identifiers: [ProductEntity.ID]) async throws -> [ProductEntity] {
        let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
            .from("catalogs")
            .select()
            .in("id", values: identifiers.map { $0.uuidString })
            .execute()
            .value
            
        return catalogs.map { ProductEntity(from: $0) }
    }
    
    func entities(matching string: String) async throws -> [ProductEntity] {
        let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
            .from("catalogs")
            .select()
            .or("name.ilike.%\(string)%,brand.ilike.%\(string)%")
            .execute()
            .value
            
        return catalogs.map { ProductEntity(from: $0) }
    }
    
    func suggestedEntities() async throws -> [ProductEntity] {
        let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
            .from("catalogs")
            .select()
            .limit(10)
            .execute()
            .value
            
        return catalogs.map { ProductEntity(from: $0) }
    }
}
