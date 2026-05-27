import os

files_to_fix_assigned_to = [
    "luxury/Core/SalesAssociate/Profile/ViewModels/SAProfileViewModel.swift",
    "luxury/Core/BoutiqueManager/Dashboard/ViewModels/DashboardViewModel.swift",
    "luxury/Core/BoutiqueManager/Dashboard/Views/BMAppointmentDetailView.swift",
]

for file in files_to_fix_assigned_to:
    with open(file, "r") as f:
        content = f.read()
    content = content.replace("assigned_staff_id", "assigned_to")
    with open(file, "w") as f:
        f.write(content)

files_to_fix_timestamp = [
    "luxury/Core/SalesAssociate/Profile/ViewModels/SAProfileViewModel.swift",
    "luxury/Core/SalesAssociate/Clienteling/ViewModels/ClientDetailViewModel.swift"
]

for file in files_to_fix_timestamp:
    with open(file, "r") as f:
        content = f.read()
    content = content.replace("appointment_date", "timestamp")
    with open(file, "w") as f:
        f.write(content)

