//
//  LoggerConfig.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation
#if os(watchOS)
import WatchKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public struct LogConfiguration {
    let identifier: String
    let currentDevice: String
    let osVersion: String
    let appVersion: String
    
    public init(identifier: String, currentDevice: String, osVersion: String, appVersion: String) {
        self.identifier = identifier
        self.currentDevice = currentDevice
        self.osVersion = osVersion
        self.appVersion = appVersion
    }
    
    @MainActor public init(identifier: String, appVersion: String) {
        self.identifier = identifier
        self.appVersion = appVersion
        
        let processInfo = ProcessInfo.processInfo
        let operationSystemVersion = processInfo.operatingSystemVersion
        self.osVersion = "\(operationSystemVersion.majorVersion).\(operationSystemVersion.minorVersion).\(operationSystemVersion.patchVersion)"
#if os(macOS)
        var size: Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        if sysctlbyname("hw.model", &machine, &size, nil, 0) != 0 {
            self.currentDevice = "Mac"
        } else {
            let code: String = String(cString: machine)
            self.currentDevice = code
        }
#elseif os(iOS) || os(tvOS)
        self.currentDevice = UIDevice.current.name
#elseif os(watchOS)
        self.currentDevice = WKInterfaceDevice.current().name
#else
        self.currentDevice = processInfo.hostName
#endif
    }
    
    var category: String {
        let currentTime = Date.now
        return "\(currentTime.formatter()) \(self.currentDevice) \(self.osVersion) \(self.identifier) \(self.appVersion)"
    }
}
