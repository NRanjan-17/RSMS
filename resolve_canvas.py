import re
with open('luxury/Core/SalesAssociate/SalesAssociateCanvas.swift', 'r') as f:
    text = f.read()

resolved = re.sub(
    r'<<<<<<< HEAD.*?case \.transactionDetail\(let tx\):\n            SATransactionDetailView\(transaction: tx\)\n        case \.createAppointment:\n            CreateAppointmentView\(\)\n=======\n        case \.createAppointment\(let client\):\n            CreateAppointmentView\(client: client\)\n>>>>>>> feature/appointments',
    r'        case .transactionDetail(let tx):\n            SATransactionDetailView(transaction: tx)\n        case .createAppointment(let client):\n            CreateAppointmentView(client: client)',
    text, flags=re.DOTALL
)

with open('luxury/Core/SalesAssociate/SalesAssociateCanvas.swift', 'w') as f:
    f.write(resolved)
