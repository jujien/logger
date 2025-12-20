//
//  Date+Ext.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//
import Foundation

extension Date {
    internal func formatter(pattern: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        return dateFormatter.string(from: self)
    }
}
