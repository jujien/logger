//
//  RecordLogger.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation

open class RecordLogger {
    public var tag: String
    private let config: LogConfiguration
    private let url: URL?
    
    private var logFileURL: URL? {
        if let url {
            return url.appendingPathComponent("\(Date.now.formatter(pattern: "yyyyMMdd")).log")
        } else {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                return url.appendingPathComponent("logs/\(Date.now.formatter(pattern: "yyyyMMdd")).log")
            }
            return nil
        }
    }
    
    private var logFolderURL: URL? {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("logs")
        }
        return nil
    }
    
    public init(tag: String, config: LogConfiguration, url: URL? = nil) {
        self.tag = tag
        self.config = config
        self.url = url
    }
    
    private func createFolderIfNeeded() {
        if let logFolderURL {
            if !FileManager.default.fileExists(atPath: logFolderURL.path) {
                do {
                    try FileManager.default.createDirectory(at: logFolderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating log folder: \(error)")
                }
            }
        }
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
    
    func removeAllOldLog(maximumLogAlive: Int) async {
        guard var logFileURL else { return }
        logFileURL.deleteLastPathComponent()
        guard let contents = try? FileManager.default.contentsOfDirectory(at: logFileURL, includingPropertiesForKeys: nil) else {
            return
        }
        for file in contents {
            do {
                try await self.removeOldLog(url: file, maximumLogAlive: maximumLogAlive)
            } catch {
                print("Error remove old log: \(error)")
            }
        }
    }
    
    private func removeOldLog(url: URL, maximumLogAlive: Int) async throws {
        try await Task.detached {
            guard FileManager.default.fileExists(atPath: url.path) else {
                return print("File not existed")
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let creationDate = attributes[.creationDate] as? Date else {
                return print("Can't get creation date")
            }
            let currentDate = Date.now
            let timeIntervalMinmumAlive = currentDate.timeIntervalSince1970 - Double(maximumLogAlive) * 24 * 60 * 60
            if creationDate.timeIntervalSince1970 < timeIntervalMinmumAlive {
                try FileManager.default.removeItem(at: url)
            }
        }.value
    }
}

extension RecordLogger: Logger {
    public func isLoggable(priority: Int, tag: String) -> Bool {
        return LogLevel.supported.contains(where: { $0.rawValue == UInt8(priority) })
    }
    
    public func log(priority: Int, message: String?, args: [any CVarArg], error: (any Error)?) {
        guard let logFileURL else { return }
        if !self.isLoggable(priority: priority, tag: self.tag) {
            return
        }
        guard let level = LogLevel(rawValue: UInt8(priority)) else {
            return
        }
        self.createFolderIfNeeded()

        let category = self.config.category
        let symbol = switch level {
        case .debug: "D"
        case .info: "I"
        case .warning, .notice, .critical: "W"
        case .error, .fault: "E"
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
                log += " - \(error.localizedDescription)"
            }
            self.write("\n\(log)", url: logFileURL)
            
        } else if let error {
            let log = if !self.tag.isEmpty {
                "\(category) \(symbol) [\(self.tag)] \(error.localizedDescription)"
            } else {
                "\(category) \(symbol) \(error.localizedDescription)"
            }
            self.write("\n\(log)", url: logFileURL)
        }
    }
}
