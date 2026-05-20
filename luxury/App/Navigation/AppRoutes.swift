//
//  AppRoutes.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

enum SARoute: Hashable {
    case clientProfile(Client)
    case newClient
    case editClient(Client)
    case productDetail(Product)
    case barcodeScanner
    case payment
    case receipt
    case appointmentList
    case createAppointment
    case returns
    case afterSalesIntake
    case afterSalesTracking
    case lookBuilder
    case remoteSelling
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
    case associateRequestDetail(SalesAssociate)
    case controllerRequestDetail(InventoryController)

}

enum ICRoute: Hashable {
    case stockDetail(InventoryAlert)
    case stockSearch
    case scanSessionDetail(ScanSession)
    case activeScan
    case transferDetail(TransferRequest)
    case newTransfer
    case auditDetail(RSMSCycleCount)
    case activeAudit
    case serialCertificate
}

enum CARoute: Hashable {
    case globalAnalytics
    case userManagement
    case boutiqueConfig
    case boutiqueConfigDetail(CorporateBoutique)
    case systemLogs
    case boutiqueRequestDetail(CorporateBoutique)
    case pendingBoutiques
    case boutiqueDetail(CorporateBoutique)
}

enum AppRoutes: Hashable {
    case splash
    case auth
    case salesAssociateCanvas
    case boutiqueManagerCanvas
    case inventoryControllerCanvas
    case corporateAdminCanvas
}
