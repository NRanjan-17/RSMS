import re

with open("luxury/Core/SalesAssociate/SalesAssociateCanvas.swift", "r") as f:
    content = f.read()

if "case .transactionList" not in content:
    content = content.replace(
        "case .exchangePolicy:\n            ExchangePolicyView()",
        "case .exchangePolicy:\n            ExchangePolicyView()\n        case .transactionList(let txs):\n            SATransactionListView(transactions: txs)"
    )
    with open("luxury/Core/SalesAssociate/SalesAssociateCanvas.swift", "w") as f:
        f.write(content)

