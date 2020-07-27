//
//  Semphore.swift
//  ARSort
//
//  Created by CuiZihan on 2020/7/24.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import Foundation

public protocol SemphoreDelegate {
    func getSemphore()
    func releaseSemphore()
}
