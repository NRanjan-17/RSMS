import re
import sys

def resolve(file, resolutions):
    with open(file, 'r') as f:
        text = f.read()

    pattern = re.compile(r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> [^\n]+\n', re.DOTALL)
    matches = list(pattern.finditer(text))
    
    if len(matches) != len(resolutions):
        print(f"Error in {file}: expected {len(matches)} resolutions, got {len(resolutions)}")
        return

    offset = 0
    for match, res in zip(matches, resolutions):
        start, end = match.span()
        start += offset
        end += offset
        
        head = match.group(1)
        incoming = match.group(2)
        
        if res == 'H':
            replacement = head + '\n'
        elif res == 'I':
            replacement = incoming + '\n'
        elif res == 'B':
            replacement = head + '\n' + incoming + '\n'
        elif callable(res):
            replacement = res(head, incoming) + '\n'
        else:
            replacement = res + '\n'
            
        text = text[:start] + replacement + text[end:]
        offset += len(replacement) - (end - start)
        
    with open(file, 'w') as f:
        f.write(text)
    print(f"Resolved {file}")

resolve('luxury/Core/SalesAssociate/Clienteling/Views/AppointmentListView.swift', ['I', 'I', 'I', 'I'])
resolve('luxury/Core/SalesAssociate/Clienteling/Views/ClientProfileView.swift', ['I'])
resolve('luxury/Core/SalesAssociate/Clienteling/Views/CreateAppointmentView.swift', ['I', 'I', 'I', 'I', 'I', 'I', 'I'])

