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
    case afterSalesIntake(client: Client, serialNumber: String?, isWarrantyActive: Bool)
    case afterSalesTracking
    case remoteSelling
    case purchaseDetails(client: Client, purchase: ClientPurchase)
    case exchangePolicy
}


enum BMRoute: Hashable {
    case appointmentDetail(AppointmentEntity)
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
    case endlessAisleRequests
}

enum ICRoute: Hashable {
    case stockDetail(InventoryAlert)
    case stockSearch
    case scanSessionDetail(ScanSession)
    case barcodeScan
    case transferDetail(TransferRequest)
    case newTransfer
    case auditDetail(RSMSCycleCount)
    case activeAudit(RSMSCycleCount)
    case varianceReport(RSMSCycleCount)
    case serialCertificate
    case sfsOrders
    case sfsVerification(PurchasedItemEntity)
    case endlessAisleSelection
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
    case staffList
    case staffDetail(StaffModel)
    case storePerformance
    case storePerformanceDetail(BoutiquePerformance)
}

enum AppRoutes: Hashable {
    case splash
    case auth
    case salesAssociateCanvas
    case boutiqueManagerCanvas
    case inventoryControllerCanvas
    case corporateAdminCanvas
}
