//
//  Log.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation

public class Log: @unchecked Sendable {
    
    private var loggers: [any Logger] = []
    
    private static let shared: Log = .init()
    
    private init() { }
    
    @MainActor
    static func `init`(
        identifier: String,
        appVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil
    ) {
        Log.shared.config(identifier: identifier, appVersion: appVersion)
    }
    
    static func `init`(
        identifier: String,
        appVersion: String,
        currentDevice: String, osVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil
    ) {
        Log.shared.config(
            identifier: identifier,
            appVersion: appVersion,
            currentDevice: currentDevice,
            osVersion: osVersion
        )
    }
    
    static func insert(_ logger: any Logger) {
        Log.shared.insert(log: logger)
    }
    
    static func tag(_ tag: String) -> Log {
        Log.shared.tag(tag)
    }
    
    static func debug(_ message: String, args: [CVarArg] = []) {
        Log.shared.debug(message, args: args)
    }
    
    static func info(_ message: String, args: [CVarArg] = []) {
        Log.shared.info(message, args: args)
    }
    
    static func warning(_ message: String, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.warning(message, args: args, error: error)
    }
    
    static func error(_ message: String, args: [CVarArg], error: Error?) {
        Log.shared.error(message, args: args, error: error)
    }
    
    static func trace(_ message: String, args: [CVarArg], error: Error?) {
        Log.shared.trace(message, args: args, error: error)
    }
    
    static func log(
        level: Int,
        _ message: String,
        args: [CVarArg] = [],
        error: Error? = nil
    ) {
        Log.shared
            .loggers
            .forEach {
                $0.log(priority: level, message: message, args: args, error: error)
            }
    }
    
    
    @MainActor
    private func config(
        identifier: String,
        appVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil
    ) {
        let config: LogConfiguration = .init(identifier: identifier, appVersion: appVersion)
        self.insert(log: DebugLogger(tag: "", config: config))
        if supportRecord {
            self.loggers.append(RecordLogger(tag: "", config: config, url: logFileURL))
        }
        
    }
    
    private func config(
        identifier: String,
        appVersion: String,
        currentDevice: String, osVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil
    ) {
        let config: LogConfiguration = .init(identifier: identifier, currentDevice: currentDevice, osVersion: osVersion, appVersion: appVersion)
        self.insert(log: DebugLogger(tag: "", config: config))
        if supportRecord {
            self.loggers.append(RecordLogger(tag: "", config: config, url: logFileURL))
        }
    }
    
    
    private func tag(_ tag: String) -> Self {
        for var logger in loggers {
            logger.tag = tag
        }
        return self
    }
    
    private func insert(log: any Logger) {
        loggers.append(log)
    }
    
    private func debug(_ message: String, args: [CVarArg]) {
        loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.debug.rawValue), message: message, args: args, error: nil)
        }
    }
    
    private func info(_ message: String, args: [CVarArg]) {
        loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.info.rawValue), message: message, args: args, error: nil)
        }
    }
    
    private func warning(_ message: String, args: [CVarArg], error: Error?) {
        loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.warning.rawValue), message: message, args: args, error: error)
        }
    }
    
    private func error(_ message: String, args: [CVarArg], error: Error?) {
        loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.error.rawValue), message: message, args: args, error: error)
        }
    }
    
    private func trace(_ message: String, args: [CVarArg], error: Error?) {
        loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.trace.rawValue), message: message, args: args, error: error)
        }
    }
    
}
