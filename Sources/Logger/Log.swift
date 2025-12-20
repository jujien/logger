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
    public static func `init`(
        identifier: String,
        appVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil,
        supportRemoveOldLog: Bool = true,
        maximumLogAlive: Int = 30
    ) {
        Log.shared
            .config(
            identifier: identifier,
            appVersion: appVersion,
            supportRecord: supportRecord,
            logFileURL: logFileURL,
            supportRemoveOldLog: supportRemoveOldLog,
            maximumLogAlive: maximumLogAlive
        )
    }
    
    public static func `init`(
        identifier: String,
        appVersion: String,
        currentDevice: String, osVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil,
        supportRemoveOldLog: Bool = true,
        maximumLogAlive: Int = 30
    ) {
        Log.shared.config(
            identifier: identifier,
            appVersion: appVersion,
            currentDevice: currentDevice,
            osVersion: osVersion,
            supportRecord: supportRecord,
            logFileURL: logFileURL,
            supportRemoveOldLog: supportRemoveOldLog,
            maximumLogAlive: maximumLogAlive
        )
    }
    
    public static func insert(_ logger: any Logger) {
        Log.shared.insert(log: logger)
    }
    
    public static func tag(_ tag: String) -> Log {
        Log.shared.tag(tag)
    }
    
    public static func debug(_ message: String, args: [CVarArg] = []) {
        Log.shared.debug(message, args: args)
    }
    
    public static func info(_ message: String, args: [CVarArg] = []) {
        Log.shared.info(message, args: args)
    }
    
    public static func warning(_ message: String, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.warning(message, args: args, error: error)
    }
    
    public static func error(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.error(message, args: args, error: error)
    }
    
    public static func trace(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.trace(message, args: args, error: error)
    }
    
    public static func notice(_ message: String, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.notice(message, args: args, error: error)
    }
    
    public static func fault(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.fault(message, args: args, error: error)
    }
    
    public static func critical(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        Log.shared.critical(message, args: args, error: error)
    }
    
    public static func log(
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
        logFileURL: URL? = nil,
        supportRemoveOldLog: Bool = true,
        maximumLogAlive: Int = 30
    ) {
        let config: LogConfiguration = .init(identifier: identifier, appVersion: appVersion)
        self.insert(log: DebugLogger(tag: "", config: config))
        if supportRecord {
            self.loggers.append(RecordLogger(tag: "", config: config, url: logFileURL))
            if supportRemoveOldLog {
                self.removeOldLog(maximumLogAlive: maximumLogAlive)
            }
        }
        
    }
    
    private func config(
        identifier: String,
        appVersion: String,
        currentDevice: String, osVersion: String,
        supportRecord: Bool = true,
        logFileURL: URL? = nil,
        supportRemoveOldLog: Bool = true,
        maximumLogAlive: Int = 30
    ) {
        let config: LogConfiguration = .init(identifier: identifier, currentDevice: currentDevice, osVersion: osVersion, appVersion: appVersion)
        self.insert(log: DebugLogger(tag: "", config: config))
        if supportRecord {
            self.loggers.append(RecordLogger(tag: "", config: config, url: logFileURL))
            if supportRemoveOldLog {
                self.removeOldLog(maximumLogAlive: maximumLogAlive)
            }
        }
    }
    
    private func removeOldLog(maximumLogAlive: Int) {
        guard let recordLogger = self.loggers.first(where: { $0 is RecordLogger }) as? RecordLogger else { return }
        Task {
            await recordLogger.removeAllOldLog(maximumLogAlive: maximumLogAlive)
        }
    }
    
    
    private func tag(_ tag: String) -> Self {
        for var logger in loggers {
            logger.tag = tag
        }
        return self
    }
    
    private func insert(log: any Logger) {
        self.loggers.append(log)
    }
    
    public func debug(_ message: String, args: [CVarArg] = []) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.debug.rawValue), message: message, args: args, error: nil)
        }
    }
    
    public func info(_ message: String, args: [CVarArg] = []) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.info.rawValue), message: message, args: args, error: nil)
        }
    }
    
    public func warning(_ message: String, args: [CVarArg] = [], error: Error? = nil) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.warning.rawValue), message: message, args: args, error: error)
        }
    }
    
    public func error(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.error.rawValue), message: message, args: args, error: error)
        }
    }
    
    public func trace(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.trace.rawValue), message: message, args: args, error: error)
        }
    }
    
    public func critical(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.critical.rawValue), message: message, args: args, error: error)
        }
    }
    
    public func fault(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.fault.rawValue), message: message, args: args, error: error)
        }
    }
    
    public func notice(_ message: String? = nil, args: [CVarArg] = [], error: Error? = nil) {
        self.loggers.forEach { logger in
            logger.log(priority: Int(LogLevel.notice.rawValue), message: message, args: args, error: error)
        }
    }
    
}
