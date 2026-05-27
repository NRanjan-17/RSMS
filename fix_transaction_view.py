import re

with open("luxury/Core/SalesAssociate/Profile/Views/SATransactionListView.swift", "r") as f:
    content = f.read()

bad_block = """                if let date = transaction.dateOfTransaction {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
                    Text(formatter.string(from: date))
                        .font(AppFonts.sansSerif(size: 11))
                        .foregroundStyle(AppColors.secondary)
                }"""
                
good_block = """                if let date = transaction.dateOfTransaction {
                    Text(formatDate(date))
                        .font(AppFonts.sansSerif(size: 11))
                        .foregroundStyle(AppColors.secondary)
                }"""

content = content.replace(bad_block, good_block)

func_block = """    var body: some View {"""
new_func_block = """    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    var body: some View {"""
    
content = content.replace(func_block, new_func_block)

with open("luxury/Core/SalesAssociate/Profile/Views/SATransactionListView.swift", "w") as f:
    f.write(content)

