with open("luxury/Core/InventoryController/Audit/ViewModels/ActiveAuditViewModel.swift", "r") as f:
    lines = f.readlines()

# We need to find the `return .failure(error)` line and insert `    }` two lines below it.
for i, line in enumerate(lines):
    if "return .failure(error)" in line:
        lines.insert(i + 2, "    }\n\n")
        break

# Let's clean up any double '}' at the end of the file.
if lines[-1].strip() == "}":
    if lines[-2].strip() == "}":
        if lines[-3].strip() == "}":
            lines.pop() # remove one extra '}'

with open("luxury/Core/InventoryController/Audit/ViewModels/ActiveAuditViewModel.swift", "w") as f:
    f.writelines(lines)
