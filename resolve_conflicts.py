import re

files = [
    "luxury/Core/SalesAssociate/Clienteling/Views/AppointmentListView.swift",
    "luxury/Core/SalesAssociate/Profile/ViewModels/SAProfileViewModel.swift",
    "luxury/Core/SalesAssociate/Profile/Views/ProfileView.swift"
]

for file in files:
    with open(file, "r") as f:
        content = f.read()

    # We want to keep HEAD (our changes) and discard the incoming changes (origin/main)
    # The pattern for git conflict markers is:
    # <<<<<<< HEAD
    # (our changes)
    # =======
    # (their changes)
    # >>>>>>> (commit hash)
    
    # We will use regex to find and replace
    pattern = re.compile(r'<<<<<<< HEAD\n(.*?)\n=======\n.*?\n>>>>>>> [a-f0-9]+', re.DOTALL)
    
    new_content = pattern.sub(r'\1', content)
    
    with open(file, "w") as f:
        f.write(new_content)

