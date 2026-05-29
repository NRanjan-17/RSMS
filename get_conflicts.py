import re
import sys

def show_conflicts(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    pattern = re.compile(r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> [^\n]+\n', re.DOTALL)
    matches = pattern.finditer(content)
    
    for i, match in enumerate(matches):
        print(f"--- Conflict {i+1} in {filepath} ---")
        print("HEAD (main):\n" + match.group(1))
        print("INCOMING (feature/appointments):\n" + match.group(2))
        print("-" * 40)

show_conflicts('luxury/Core/SalesAssociate/Clienteling/Views/AppointmentListView.swift')
show_conflicts('luxury/Core/SalesAssociate/Clienteling/Views/ClientProfileView.swift')
show_conflicts('luxury/Core/SalesAssociate/Clienteling/Views/CreateAppointmentView.swift')
