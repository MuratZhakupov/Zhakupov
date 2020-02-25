//
//  Shedule.swift
//  Zhakupov
//
//  Created by Murat Zhakupov on 2/25/20.
//  Copyright © 2020 Murat Zhakupov. All rights reserved.
//

import Foundation

struct Shedule: Codable {
    
    var name: String
    var startTime: String
    var endTime: String
    var teacher: String
    var place: String
    var description: String
    var weekDay: Int
}

class ShedulesListForSave: Codable {
    
    var list: [Shedule] = [Shedule]()
}
