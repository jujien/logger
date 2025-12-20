//
//  DebugLogger.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation
import os 

open class DebugLogger {
    public var tag: String
    private let config: LogConfiguration
    private let logger: os.Logger
    
    public init(tag: String, config: LogConfiguration) {
        self.tag = tag
        self.config = config
        self.logger = os.Logger(subsystem: config.identifier, category: tag)
    }
}

extension DebugLogger: Logger {
    public func log(priority: Int, message: String?, args: [any CVarArg], error: (any Error)?) {
        if !self.isLoggable(priority: priority, tag: self.tag) {
            return
        }
        guard let level = LogLevel(rawValue: UInt8(priority)) else {
            return
        }

        let category = self.config.category
        let symbol = switch level {
        case .debug: "🐞"
        case .info: "ℹ️"
        case .warning: "⚠️"
        case .error: "‼️"
        case .trace: "🔎"
        case .fault: "💣"
        case .critical: "💥"
        case .notice: "🔔"
        default: ""
        }
        if let message = message {
            var log = if !self.tag.isEmpty {
                "\(category) \(symbol) [\(self.tag)] \(self.formatMessage(message: message, args: args))"
            } else {
                "\(category) \(symbol) \(self.formatMessage(message: message, args: args))"
            }
            if let error {
                log += " - \(error.localizedDescription)"
            }
            switch level {
            case .debug: self.logger.debug("\(log)")
            case .info: self.logger.info("\(log)")
            case .warning: self.logger.warning("\(log)")
            case .error: self.logger.error("\(log)")
            case .trace: self.logger.trace("\(log)")
            case .fault: self.logger.fault("\(log)")
            case .notice: self.logger.notice("\(log)")
            case .critical: self.logger.critical("\(log)")
            default: self.logger.debug("\(log)")
            }
        } else if let error {
            let log = if !self.tag.isEmpty {
                "\(category) \(symbol) [\(self.tag)] \(error.localizedDescription)"
            } else {
                "\(category) \(symbol) \(error.localizedDescription)"
            }
            self.logger.error("\(log)")
        }
        
    }
    
    public func isLoggable(priority: Int, tag: String) -> Bool {
        return LogLevel.supported.contains(where: { $0.rawValue == UInt8(priority) })
    }
}
