import SwiftUI

enum SARoute: Hashable {
    case clientProfile(Client)
    case newClient
    case editClient(Client)
    case catalogDetail(CatalogEntity)
    case barcodeScanner
    case payment
    case receipt
    case appointmentList
    case createAppointment
    case returns
    case afterSalesIntake(clientName: String?, serialNumber: String?, isWarrantyActive: Bool)
    case afterSalesTracking
    case lookBuilder
    case remoteSelling
    case purchaseDetails(client: Client, purchase: ClientPurchase)
}


enum BMRoute: Hashable {
    case appointmentDetail(BMAppointment)
    case staffPerformanceDetail(BMStaffMember)
    case createEvent
    case salesAnalytics
    case staffPerformanceReport
    case shrinkReport
    case clientInsights
    case transferApproval
    case cycleCountSignoff
    case refundApproval
    case writeOffApproval
    case staffRequestDetail(StaffModel)
    case pendingStaff
    case staffDetail(StaffModel)
}

enum ICRoute: Hashable {
    case stockDetail(InventoryAlert)
    case stockSearch
    case scanSessionDetail(ScanSession)
    case barcodeScan
    case transferDetail(TransferRequest)
    case newTransfer
    case auditDetail(RSMSCycleCount)
    case activeAudit
    case serialCertificate
    case sfsOrders
    case sfsVerification(PurchasedItemEntity)
    case catalogDetail(CatalogEntity, Int)
}

enum CARoute: Hashable {
    case globalAnalytics
    case userManagement
    case catalogs
    case catalogForm(editCatalog: CatalogEntity?)
    case catalogDetail(CatalogEntity)
    case boutiqueConfig
    case boutiqueConfigDetail(CorporateBoutique)
    case systemLogs
    case boutiqueRequestDetail(CorporateBoutique)
    case pendingBoutiques
    case boutiqueDetail(CorporateBoutique)
    case inventoryDetail(ProductInventorySummary)
}

enum AppRoutes: Hashable {
    case splash
    case auth
    case salesAssociateCanvas
    case boutiqueManagerCanvas
    case inventoryControllerCanvas
    case corporateAdminCanvas
}
