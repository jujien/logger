//
//  Date+Ext.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//
import Foundation

extension Date {
    func formatter(pattern: String = "yyyyMMdd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        return dateFormatter.string(from: self)
    }
}
