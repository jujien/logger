//
//  RecordLogger.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation

class RecordLogger {
    var tag: String
    private let config: LogConfiguration
    private let url: URL?
    
    private var logFileURL: URL? {
        if let url {
            return url
        } else {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                return url.appendingPathComponent("\(Date.now.formatter(pattern: "yyyyMMdd")).log")
            }
            return nil
        }
    }
    
    init(tag: String, config: LogConfiguration, url: URL? = nil) {
        self.tag = tag
        self.config = config
        self.url = url
    }
    
    private func write(_ message: String, url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: url)
                try fileHandle.seekToEnd()
                if let data = message.data(using: .utf8) {
                    try fileHandle.write(contentsOf: data)
                }
            } catch {
                print("Error writing to log file: \(error)")
            }
        } else {
            do {
                try message.write(toFile: url.path, atomically: true, encoding: .utf8)
            } catch {
                print("Error creating log file: \(error)")
            }
        }
    }
}

extension RecordLogger: Logger {
    func isLoggable(priority: Int, tag: String) -> Bool {
        return LogLevel.supported.contains(where: { $0.rawValue == UInt8(priority) })
    }
    
    func log(priority: Int, message: String?, args: [any CVarArg], error: (any Error)?) {
        guard let logFileURL else { return }
        if !self.isLoggable(priority: priority, tag: self.tag) {
            return
        }
        guard let level = LogLevel(rawValue: UInt8(priority)) else {
            return
        }

        let category = self.config.category
        let symbol = switch level {
        case .debug: "D"
        case .info: "I"
        case .warning: "W"
        case .error: "E"
        case .trace: "T"
        default: ""
        }
        if let message = message {
            var log = if !self.tag.isEmpty {
                "\(category) \(symbol) [\(self.tag)] \(self.formatMessage(message: message, args: args))"
            } else {
                "\(category) \(symbol) \(self.formatMessage(message: message, args: args))"
            }
            if let error {
                log += ": \(error.localizedDescription)"
            }
            self.write(log, url: logFileURL)
            
        } else if let error {
            let log = if !self.tag.isEmpty {
                "\(category) \(symbol) [\(self.tag)] \(error.localizedDescription)"
            } else {
                "\(category) \(symbol) \(error.localizedDescription)"
            }
            self.write(log, url: logFileURL)
        }
    }
}
