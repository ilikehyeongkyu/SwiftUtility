//
//  BundleUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 15/04/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Bundle {
    var version: String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
            fatalError("infoDictionary[CFBundleShortVersionString] is not found.")
        }
        
        return version
    }
    var build: String {
        guard let build = infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("infoDictionary[CFBundleVersion] is not found.")
        }
        
        return build
    }
}
