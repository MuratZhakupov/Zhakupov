//
//  Connectivity.swift
//  LH stream
//
//  Created by Murat Zhakupov on 10.07.2019.
//  Copyright © 2019 Murat Zhakupov. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
