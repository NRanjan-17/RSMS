//
//  RFIDViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class RFIDViewModel {
    var recentSessions: [ScanSession] = []
}
