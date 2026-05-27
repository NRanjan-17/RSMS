import re

with open("luxury/Core/InventoryController/Audit/ViewModels/ActiveAuditViewModel.swift", "r") as f:
    content = f.read()

# Replace the entire conflict block with the HEAD version and append the new methods.
pattern = re.compile(r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> [^\n]+\n', re.DOTALL)

def replacer(match):
    head_content = match.group(1)
    
    # Actually, the conflict block wraps the entire class implementation except 'final class ActiveAuditViewModel {'
    # So we need to find the submitCount method inside head_content and insert the new methods before the final '}'
    
    return head_content + """
    var missingItems: [String] {
        return expectedItems.filter { $0.countedQty == 0 }.map { $0.name }
    }
    
    func addScannedItems(barcodes: [String]) {
        for barcode in barcodes {
            let _ = scanItem(barcode: barcode)
        }
    }
"""

fixed_content = pattern.sub(replacer, content)

with open("luxury/Core/InventoryController/Audit/ViewModels/ActiveAuditViewModel.swift", "w") as f:
    f.write(fixed_content)
