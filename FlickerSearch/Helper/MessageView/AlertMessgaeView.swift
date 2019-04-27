//
//  AlertMessgaeView.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import UIKit

class AlertMessgaeView: UIView, NibLoadableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func updateViewWith(imageName: String, message: String) {
        imageView.image = UIImage(named: imageName)
        messageLabel.text = message
    }

}
