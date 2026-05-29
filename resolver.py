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

def custom_canvas(head, incoming):
    return """        case .transactionDetail(let tx):
            SATransactionDetailView(transaction: tx)
        case .createAppointment(let client):
            CreateAppointmentView(client: client)"""

resolve('luxury/Core/SalesAssociate/SalesAssociateCanvas.swift', [custom_canvas])
resolve('luxury/Core/BoutiqueManager/Dashboard/Views/BMAppointmentDetailView.swift', ['H'])

def custom_bm_dashboard(head, incoming):
    return head + "\n" + incoming

resolve('luxury/Core/BoutiqueManager/Dashboard/Views/DashboardView.swift', [custom_bm_dashboard])

def custom_client_vm(head, incoming):
    return head + "\n" + incoming

resolve('luxury/Core/SalesAssociate/Clienteling/ViewModels/ClientDetailViewModel.swift', [custom_client_vm])

def custom_profile_vm(head, incoming):
    return head + "\n" + incoming

resolve('luxury/Core/SalesAssociate/Profile/ViewModels/SAProfileViewModel.swift', [custom_profile_vm])

def custom_profile_view(head, incoming):
    return head + "\n" + incoming

resolve('luxury/Core/SalesAssociate/Profile/Views/ProfileView.swift', [custom_profile_view])

