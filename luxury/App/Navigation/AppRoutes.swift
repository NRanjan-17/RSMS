import SwiftUI

enum SARoute: Hashable {
    case clientProfile(Client)
    case newClient
    case editClient(Client)
    case catalogDetail(CatalogEntity)
    case barcodeScanner
    case payment
    case receipt
    case paymentFailed(String)
    case appointmentList
    case createAppointment(Client?)
    case returns
    case transactionDetail(SATransactionEntity)
    case afterSalesIntake(client: Client, serialNumber: String?, isWarrantyActive: Bool, purchaseId: UUID? = nil)
    case afterSalesTracking
    case remoteSelling
    case purchaseDetails(client: Client, purchase: ClientPurchase)
    case exchangePolicy
    case transactionList([SATransactionEntity])
    case editProfile
    case planogramGallery(boutiqueId: UUID)
    case sfsHandover
}


enum BMRoute: Hashable {
    case allAppointments
    case appointmentDetail(AppointmentEntity)
    case staffPerformanceDetail(BMStaffMember)
    case createEvent
    case salesAnalytics
    case staffPerformanceReport
    case shrinkReport
    case clientInsights
    case transferApproval
    case newTransfer
    case cycleCountSignoff
    case stockReconciliation
    case refundApproval
    case writeOffApproval
    case staffRequestDetail(StaffModel)
    case pendingStaff
    case staffDetail(StaffModel)
    case endlessAisleRequests
    case vipPreviewDetail(StoreEvent)
    case trunkShowDetail(StoreEvent)
    case productLaunchDetail(StoreEvent)
    case editProfile
    case salesTargets
    case planogramGallery(boutiqueId: UUID)
    case pendingAppointmentsList([AppointmentEntity])
    case sfsTicketDetail(PurchasedItemEntity)
    case sfsTicketsList([PurchasedItemEntity])
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
    case alerts
    case purchaseOrders
    case poDetail(PurchaseOrder)
    case editProfile
}

enum CARoute: Hashable {

    case globalInventory
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
    case editProfile
    case planograms
    case clientInsights
    case globalRevenue
    case activeBoutiques

    case transactionDetail(SATransactionEntity)
    case sfsTicketDetail(PurchasedItemEntity)
    case sfsTicketsList([PurchasedItemEntity])
    case transactionsList([SATransactionEntity])
}

enum AppRoutes: Hashable {
    case splash
    case auth
    case salesAssociateCanvas
    case boutiqueManagerCanvas
    case inventoryControllerCanvas
    case corporateAdminCanvas
}
