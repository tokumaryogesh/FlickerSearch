//
//  Helper.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation
import UIKit

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

public protocol NibLoadableView : class{
    
}
extension NibLoadableView where Self : UIView {
    static var nibName : String {
        return String(describing: self)
    }
    static func loadNib()-> UIView{
        return  Bundle.main.loadNibNamed(Self.nibName, owner: nil, options: nil)?.first as! UIView
    }
}

