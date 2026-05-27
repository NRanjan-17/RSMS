import re

with open("luxury/Core/SalesAssociate/Profile/Views/ProfileView.swift", "r") as f:
    content = f.read()

# Replace StatChip(value: viewModel.statTransactions, label: "Transactions") with a Button
search = 'StatChip(value: viewModel.statTransactions, label: "Transactions")'
replacement = """Button(action: {
                                router.push(SARoute.transactionList(viewModel.recentTransactions))
                            }) {
                                StatChip(value: viewModel.statTransactions, label: "Transactions")
                            }
                            .buttonStyle(.plain)"""

if "SARoute.transactionList" not in content:
    content = content.replace(search, replacement)
    with open("luxury/Core/SalesAssociate/Profile/Views/ProfileView.swift", "w") as f:
        f.write(content)

