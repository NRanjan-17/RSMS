import re

with open("luxury/Core/SalesAssociate/Profile/ViewModels/SAProfileViewModel.swift", "r") as f:
    content = f.read()

# Add recentTransactions
if "var recentTransactions" not in content:
    content = content.replace(
        "var recentClients: [SADashClient] = []",
        "var recentClients: [SADashClient] = []\n    var recentTransactions: [SATransactionEntity] = []"
    )

# Replace fetchStats
fetch_stats_regex = r"private func fetchStats\(staffId: UUID\) async \{.*?print\(\"Failed to fetch stats: \\\(error\)\"\)\n        \}\n    \}"
new_fetch_stats = """private func fetchStats(staffId: UUID) async {
        do {
            let txs: [SATransactionEntity] = try await SupabaseManager.shared.client
                .from("transaction")
                .select("*, client:client_id(*)")
                .eq("staff_id", value: staffId)
                .order("date_of_transaction", ascending: false)
                .execute()
                .value
            
            let totalRevenue = txs.reduce(0.0) { $0 + $1.transactionAmount }
            
            // Extract unique clients
            var seenClients = Set<UUID>()
            var mappedClients: [SADashClient] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            
            for tx in txs {
                guard let client = tx.client else { continue }
                if !seenClients.contains(client.id) {
                    seenClients.insert(client.id)
                    let visitStr = tx.dateOfTransaction.map { formatter.string(from: $0) } ?? "Unknown"
                    let initial = String(client.name.prefix(1)).uppercased()
                    let dashClient = SADashClient(
                        name: client.name,
                        tier: client.tier ?? "Standard",
                        lastVisit: visitStr,
                        ltv: totalRevenue, // simplified, ideally from client LTV
                        initial: initial.isEmpty ? "U" : initial
                    )
                    mappedClients.append(dashClient)
                }
            }
            
            await MainActor.run {
                self.revenue = totalRevenue
                self.statTransactions = "\\(txs.count)"
                self.statClients = "\\(mappedClients.count)"
                self.recentClients = mappedClients
                self.recentTransactions = txs
            }
        } catch {
            print("Failed to fetch stats: \\(error)")
        }
    }"""

content = re.sub(fetch_stats_regex, new_fetch_stats, content, flags=re.DOTALL)

with open("luxury/Core/SalesAssociate/Profile/ViewModels/SAProfileViewModel.swift", "w") as f:
    f.write(content)

