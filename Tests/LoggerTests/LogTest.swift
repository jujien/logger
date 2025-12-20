//
//  LogTest.swift
//  Logger
//
//  Created by Kiên Vũ on 7/11/24.
//

import Foundation
import Testing
@testable import Logger


@Test func testDebug() async throws {
    Log.`init`(identifier: "com.abc.def", appVersion: "1.0.0", currentDevice: "iPhone", osVersion: "16.0.0", supportRecord: false)
    Log.debug("Test debug")
}

