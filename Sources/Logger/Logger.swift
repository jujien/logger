//
//  Logger.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation
import os

public struct LogLevel: Equatable, RawRepresentable, Sendable {
    public typealias RawValue = UInt8
    
    public var rawValue: UInt8
    
    public init?(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static let debug = LogLevel(rawValue: 1 << 0)!
    public static let info = LogLevel(rawValue: 1 << 1)!
    public static let warning = LogLevel(rawValue: 1 << 2)!
    public static let error = LogLevel(rawValue: 1 << 3)!
    public static let trace = LogLevel(rawValue: 1 << 4)!
    public static let fault = LogLevel(rawValue: 1 << 5)!
    public static let notice = LogLevel(rawValue: 1 << 6)!
    public static let critical = LogLevel(rawValue: 1 << 7)!
    
#if DEBUG
    static let supported: [LogLevel] = [.debug, .info, .warning, .error, .trace, .fault, .notice, .critical]
#else
    static let supported: [LogLevel] = [.info, .warning, .error, .trace, .fault, .notice, .critical]
#endif
}

public protocol Logger {
    var tag: String { get set }
    
    func log(priority: Int, message: String?, args: [CVarArg], error: Error?)
    
    func isLoggable(priority: Int, tag: String) -> Bool
}

extension Logger {
    func formatMessage(message: String, args: [CVarArg]) -> String {
        return String(format: message, arguments: args)
    }
    
    public func isLoggable(priority: Int, tag: String) -> Bool {
        return true
    }
    
    func log(priority: Int, message: String?, args: [CVarArg], error: Error?) {
        if !self.isLoggable(priority: priority, tag: self.tag) {
            return
        }
        if let message {
            print(self.formatMessage(message: message, args: args))
        } else if let error {
            print("\(error.localizedDescription)")
        }
    }
}

