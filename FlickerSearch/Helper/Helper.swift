//
//  Helper.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation

public protocol ClassName : class {
    
}
extension ClassName {
    var className : String {
        return String(describing: self)
    }
    static  var className : String {
        return String(describing: self)
    }
}

