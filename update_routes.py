import re

with open("luxury/App/Navigation/AppRoutes.swift", "r") as f:
    content = f.read()

if "case transactionList" not in content:
    content = content.replace(
        "case exchangePolicy",
        "case exchangePolicy\n    case transactionList([SATransactionEntity])"
    )
    with open("luxury/App/Navigation/AppRoutes.swift", "w") as f:
        f.write(content)

